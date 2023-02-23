return {
  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      watch_gitdir = {
        interval = 2000,
      },
      trouble = true,
      update_debounce = 1000,
      on_attach = function (bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']h', function()
          if vim.wo.diff then return ']h' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true})

        map('n', '[h', function()
          if vim.wo.diff then return '[h' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true})

        -- Actions
        map({'n', 'v'}, '<leader>ghs', gs.stage_hunk)
        map({'n', 'v'}, '<leader>ghx', gs.reset_hunk)
        map('n', '<leader>ghu', gs.undo_stage_hunk)
        map('n', '<leader>ghX', gs.reset_buffer)
        map('n', '<leader>ghp', gs.preview_hunk)
        map('n', '<leader>ghh', function()
          gs.toggle_numhl()
          gs.toggle_word_diff()
          gs.toggle_deleted()
        end)
        map('n', '<leader>ghq', function()
          gs.setqflist("attached")
          vim.cmd("copen")
        end)
        map('n', '<leader>gbl', function() gs.blame_line{full=true} end)
        map('n', '<leader>gbb', gs.toggle_current_line_blame)
        map('n', '<leader>gdt', gs.diffthis)

        -- Text object
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end,
    },
  },

  { "tpope/vim-fugitive" },
  { "tpope/vim-rhubarb" },
  {
    "rbong/vim-flog",
    cmd = { "Flog" },
  },
  -- Neogit (fugitive alternative)
  -- {
  --   "TimUntersberger/neogit",
  --   cmd = "Neogit",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {
  --     kind = "split",
  --     disable_context_highlighting = true,
  --     disable_commit_confirmation = false,
  --     disable_insert_on_commit = false,
  --     disable_hint = true,
  --     integrations = {
  --       diffview = true,
  --     },
  --     sections = {
  --       stashes = {
  --         folded = true
  --       },
  --       recent = {
  --         folded = true,
  --       },
  --     }
  --   }
  -- },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    config = function ()
      local actions = require("diffview.actions")
      require("diffview").setup({
        view = {
          default = {
            winbar_info = true,
          },
          merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = true,
          },
          file_history = {
            winbar_info = true,
          },
        },
        diff_binaries = false,
        enhanced_diff_hl = true,
        use_icons = true,
        file_panel = {
          win_config = {
            position = "bottom",
            width = 35,
            height = 10,
          }
        },
        file_history_panel = {
          git = {
            log_options = {
              single_file = {
                follow = true,
                all = true,
              },
              multi_file = {
                all = false,
              },
            },
          },
        },
        key_bindings = {
          view = {
            ["<tab>"] = actions.select_next_entry,
            ["<s-tab>"] = actions.select_prev_entry,
            ["<leader>nf"] = actions.focus_files,
            ["<leader>nn"] = actions.toggle_files,
            ["[x"] = actions.prev_conflict,
            ["]x"] = actions.next_conflict,
            ["<leader>co"] = actions.conflict_choose("ours"),
            ["<leader>ct"] = actions.conflict_choose("theirs"),
            ["<leader>cb"] = actions.conflict_choose("all"),  -- choose both
            ["<leader>cB"] = actions.conflict_choose("base"),
            ["<leader>cx"] = actions.conflict_choose("none"),
          },
          file_panel = {
            ["j"] = actions.next_entry,
            ["<down>"] = actions.next_entry,
            ["k"] = actions.prev_entry,
            ["<up>"] = actions.prev_entry,
            ["<cr>"] = actions.select_entry,
            ["o"] = actions.select_entry,
            ["R"] = actions.refresh_files,
            ["<tab>"] = actions.select_next_entry,
            ["<s-tab>"] = actions.select_prev_entry,
            ["<leader>nf"] = actions.focus_files,
            ["<leader>nn"] = actions.toggle_files,
          },
        },
        default_args = {
          DiffviewOpen = { "--untracked-files=no" },
          DiffviewFileHistory = { "--base=LOCAL" }
        },
        -- TODO: use hooks to add buffers opened during diffview, close them on diffclose
        hooks = {
          diff_buf_read = function(_)
            vim.cmd("IndentBlanklineDisable")
          end
        },
      })
    end
  },
}
