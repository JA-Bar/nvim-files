local utils = require("utils")

local null_ls = require("null-ls")
local null_helpers = require("null-ls.helpers")

local paths = require("paths")

--           sources
-- ──────────────────────────────
local pylint = {
  name = "pylint",
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { "python" },
  generator = null_helpers.generator_factory({
    command = paths.get_cmd("pylint", {as_string = true}),
    to_stdin = true,
    from_stderr = true,
    args = {
      "--output-format",
      "text",
      "--score",
      "no",
      "--disable",
      "import-error,line-too-long",
      "--msg-template",
      [["{line}:{column}:{msg_id}:{msg}:{symbol}"]],
      "--from-stdin",
      "$FILENAME",
    },
    format = "line",
    check_exit_code = function(code)
      return code == 0
    end,
    on_output = function(line, params)
      local row, col, code, message = line:match("(%d+):(%d+):([CRWEF]%d+):(.*)")

      if message == nil then
        return nil
      end

      local end_col = col
      local severity = null_helpers.diagnostics.severities["error"]

      if vim.startswith(code, "E") or vim.startswith(code, "F") then
        severity = null_helpers.diagnostics.severities["error"]
      elseif vim.startswith(code, "W") then
        severity = null_helpers.diagnostics.severities["warning"]
      else
        severity = null_helpers.diagnostics.severities["information"]
      end

      return {
        message = message,
        code = code,
        row = row,
        col = col - 1,
        end_col = end_col,
        severity = severity,
        source = "pylint",
      }
    end,
  }),
}

local mypy = {
  name = "mypy",
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { "python" },
  generator = null_helpers.generator_factory({
    command = paths.get_cmd("mypy", {as_string = true}),
    to_stdin = true,
    from_stderr = true,
    to_temp_file = true,
    args = function(params)
      return {
        "--hide-error-context",
        "--show-column-numbers",
        "--no-pretty",
        "--shadow-file",
        params.bufname,
        params.temp_path,
        params.bufname,
      }
    end,
    format = "line",
    check_exit_code = function(code)
      return code == 0
    end,
    on_output = function(line, params)
      local row, col, code, message = line:match(":(%d+):(%d+): (.*): (.*)")

      -- --hide-error-context isn't working, as a workaround we ignore notes
      if code ~= "error" then
        return nil
      end

      -- ignores the summary line of the command's output
      if message == nil then
        return nil
      end

      local severity = null_helpers.diagnostics.severities["information"]

      return {
        message = message,
        code = code,
        row = row,
        col = col,
        end_col = col + 1,
        severity = severity,
        source = "mypy",
      }
    end,
  }),
}

local flake8 = {
  name = "flake8",
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { "python" },
  generator = null_helpers.generator_factory({
    command = utils.get_python_executable("flake8"),
    to_stdin = true,
    from_stderr = true,
    -- ignoring E203 due to false positives on list slicing
    args = { "--stdin-display-name", "$FILENAME", "-", "--ignore=E203" },
    format = "line",
    check_exit_code = function(code)
      return code == 0 or code == 255
    end,
    on_output = function(line, params)
      local row, col, message = line:match(":(%d+):(%d+): (.*)")
      local severity = null_helpers.diagnostics.severities["error"]
      -- local code = string.match(message, "[EFWCND]%d+")
      local code = string.match(message, "%u%d+")

      col = col + 1

      if message == nil then
        return nil
      end

      if vim.startswith(code, "E") then
        severity = null_helpers.diagnostics.severities["error"]
      elseif vim.startswith(code, "W") then
        severity = null_helpers.diagnostics.severities["warning"]
      else
        severity = null_helpers.diagnostics.severities["information"]
      end

      return {
        message = message,
        code = code,
        row = row,
        col = col,
        end_col = col + 1,
        severity = severity,
        source = "flake8",
      }
    end,
  }),
}

local cfn_lint = {
  name = "cfn_lint",
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { "yaml", "json"},
  generator = null_helpers.generator_factory({
    command = utils.get_python_executable("cfn-lint"),
    to_stdin = true,
    from_stderr = true,
    args = { "--format", "parseable", "-" },
    format = "line",
    check_exit_code = function(code)
      return code == 0 or code == 255
    end,
    on_output = function(line, params)
      local row, col, end_row, end_col, code, message = line:match(":(%d+):(%d+):(%d+):(%d+):(.*):(.*)")
      local severity = null_helpers.diagnostics.severities["error"]

      if message == nil then
        return nil
      end

      if vim.startswith(code, "E") then
        severity = null_helpers.diagnostics.severities["error"]
      elseif vim.startswith(code, "W") then
        severity = null_helpers.diagnostics.severities["warning"]
      else
        severity = null_helpers.diagnostics.severities["information"]
      end

      return {
        message = message,
        code = code,
        row = row,
        col = col,
        end_col = end_col,
        end_row = end_row,
        severity = severity,
        source = "cfn-lint",
      }
    end,
  }),
}

--         null-ls config
-- ──────────────────────────────
null_ls.config({
  debounce = 500,
  save_after_format = false,
  default_timeout = 20000,
  sources = {
    ---- Linters
    null_ls.builtins.diagnostics.flake8.with({
      name = "flake8",
      command = paths.get_cmd("flake8", {as_string = true}),
    }),

    require("null-ls.helpers").conditional(function(util)
      local builtin_mypy = null_ls.builtins.diagnostics.mypy.with({
        name = "mypy",
        command = paths.get_cmd("mypy", {as_string = true}),
      })
      return (util.root_has_file("mypy.ini") or util.root_has_file(".mypy.ini")) and builtin_mypy
    end),

    require("null-ls.helpers").conditional(function(util)
      return util.root_has_file("pylintrc") and pylint
    end),

    null_ls.builtins.diagnostics.luacheck.with({
      name = "luacheck",
      command = paths.get_luarock_cmd("luacheck", { as_string = true }),
      extra_args = { "--globals", "vim", "--allow-defined" },
    }),

    ---- Fixers
    null_ls.builtins.formatting.black.with({
      command = paths.get_cmd("black", {as_string = true}),
      args = { "--quiet", "--fast", "--skip-string-normalization", "-" },
    }),

    null_ls.builtins.formatting.isort.with({
      command = paths.get_cmd("isort", {as_string = true}),
    }),
    null_ls.builtins.formatting.stylua.with({
      command = paths.get_cmd("stylua", {as_string = true}),
    }),
  },
  debug = false,
})
