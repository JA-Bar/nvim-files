local actions = require('telescope.actions')


-- Global remapping
require('telescope').setup{
  defaults = {
    layout_strategy    = "flex",
    borderchars        = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    layout_config = {
      height = 0.9,
      width = 0.9,
      horizontal = {
        preview_width = 0.6,
      },
      vertical = {
        preview_width = 0.6,
      },
    },
    mappings = {
      i = {
        -- You can perform as many actions in a row as you like
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<C-h>"] = actions.preview_scrolling_up,
        ["<C-l>"] = actions.preview_scrolling_down,

        -- Send to quickfix
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,

        -- Effectively remove normal mode
        ["<esc>"] = actions.close,

        -- Change bind for horizontal split
        ["<C-s>"] = actions.select_horizontal,
      },
      n = {
        ["<esc>"] = actions.close,
      },
    },
  }
}
require('telescope').load_extension('fzy_native')

local bind_picker = require('plugins_config.utils').bind_picker


-- :Telescope find_files find_command=rg,--ignore,--hidden,--files prompt_prefix=🔍
-- Bindings
bind_picker('<Leader>ff', 'find_files')
vim.api.nvim_set_keymap(
    "n", "<Leader>fp", ":Telescope find_files find_command=rg,--files,--hidden,--no-ignore-vcs<CR>", {noremap=true, silent=true}
)

bind_picker('<Leader>fg', 'live_grep')
bind_picker('<Leader>fh', 'help_tags')
bind_picker('<Leader>ft', 'treesitter')
bind_picker('<Leader>fq', 'quickfix')
bind_picker('<Leader>fb', 'file_browser')
-- bind_picker('<Leader>fb', 'buffers')

bind_picker('<M-x>', 'commands')

-- bind_picker('<Leader>fg', 'git_status')

