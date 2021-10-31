local lspconfig = require('lspconfig')
local lsputils = require('lspconfig.util')

local paths = require('plugins_config.paths')

M = {}

--          preparation
-- ──────────────────────────────
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")


--        server settings
-- ──────────────────────────────
-- See: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
M.configurations = {
  jedi_language_server = {
    cmd = paths.get_cmd("jedi_language_server"),
    before_init = function(initialize_params, config)
      -- if no virtualenv is activated, jedi uses python's packages from the virtualenv in
      -- which it was installed. This makes it use the system's packages instead
      local env = vim.env.PYENV_VERSION
      if not env then
        config.cmd[1] = "VIRTUAL_ENV=python3 PYENV_VIRTUAL_ENV=python3 " .. config.cmd[1]
      end

      initialize_params['initializationOptions'] = {
        executable = {
          command = config.cmd[1],
        },
        jediSettings = {
          autoImportModules = {'torch', 'numpy', 'pandas', 'tensorflow'}
        },
      }
    end,
  },

  pyright = {
    cmd = paths.get_cmd("pyright"),
    -- automatically identify virtualenvs set with pyenv
    on_init = function (client)
      local python_path
      local virtual_env = vim.env.VIRTUAL_ENV
      if virtual_env then
        python_path = lsputils.path.join(virtual_env, "bin", "python")
      else
        python_path = "python"
      end
      client.config.settings.python.pythonPath = python_path
    end
  },

  sumneko_lua = {
    cmd = paths.get_cmd("sumneko_lua"),
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = runtime_path,
        },
        diagnostics = {
          globals = {'vim'},
        },
        workspace = {
          -- library = vim.api.nvim_get_runtime_file("", true),
          preloadFileSize = 350,  -- in kb
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },

  ["null-ls"] = {
  },

  dockerls = {
    cmd = paths.get_cmd('dockerls'),
  },

  jsonls = {
    cmd = paths.get_cmd('jsonls'),
  },
}

--        server registration
-- ──────────────────────────────
M.register = function(server_names, common_options)
  local options

  if type(server_names) == 'string' then
    server_names = {server_names}
  end

  for _, name in ipairs(server_names) do
    options = vim.tbl_extend('keep', M.configurations[name], common_options or {})
    lspconfig[name].setup(options)
  end
end

return M
