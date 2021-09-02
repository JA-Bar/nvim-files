local execute = vim.api.nvim_command
local fn = vim.fn

-- If Packer is not installed, download and install it
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
  execute 'packadd packer.nvim'
end

local use = require('packer').use

return require('packer').startup({function()
  -- Packer
  use {'wbthomason/packer.nvim'}

  -- Improve startup time until: https://github.com/neovim/neovim/pull/15436
  use 'lewis6991/impatient.nvim'

  -- Icons
  use 'kyazdani42/nvim-web-devicons'

  -- Colors
  use 'norcalli/nvim-colorizer.lua'
  use 'folke/tokyonight.nvim'
  use 'EdenEast/nightfox.nvim'

  -- LSP
  use 'neovim/nvim-lspconfig'
  use {'folke/lsp-trouble.nvim', requires = "kyazdani42/nvim-web-devicons"}
  use {'jose-elias-alvarez/null-ls.nvim', requires = {"nvim-lua/plenary.nvim", "neovim/nvim-lspconfig"}}

  -- LSP autocompletion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-nvim-lua'  -- check functionality
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-path'
  use 'onsails/lspkind-nvim'

  -- snippet support
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'

  -- Syntax
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use { 'nvim-treesitter/playground', opt = true, cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' }}

  -- Smooth scrolling
  use 'karb94/neoscroll.nvim'

  -- Fuzzy finding
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- Tabs
  use 'romgrk/barbar.nvim'

  --Statusline
  use {'hoob3rt/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true}}
  use {'SmiteshP/nvim-gps', requires = "nvim-treesitter/nvim-treesitter"}

  -- File tree
  use {'kyazdani42/nvim-tree.lua', opt = true, cmd = {'NvimTreeToggle', 'NvimTreeFindFile'}}

  -- Indent lines
  use 'lukas-reineke/indent-blankline.nvim'

  -- Commenting
  use 'b3nj5m1n/kommentary'

  -- Autopairs
  use 'windwp/nvim-autopairs'

  -- Surround
  use 'tpope/vim-surround'

  -- Substitution
  use 'svermeulen/vim-subversive'

  -- Tmux navigation
  use 'aserowy/tmux.nvim'

  -- Git
  use 'lewis6991/gitsigns.nvim'
  use 'tpope/vim-fugitive'
  use 'junegunn/gv.vim'
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim'}

  -- Change cwd to project
  use 'ahmedkhalf/project.nvim'

  -- Dashboard
  use 'glepnir/dashboard-nvim'

  -- Documentation generation
  use {'kkoomen/vim-doge', run=':call doge#install()', opt = true, cmd = {'DogeGenerate'}}

  -- Repeat
  use 'tpope/vim-repeat'

  -- Targets
  use 'wellle/targets.vim'

  -- Debugging
  use 'mfussenegger/nvim-dap'
  use {'rcarriga/nvim-dap-ui', requires = {'mfussenegger/nvim-dap'}}

  -- Python
  use 'Vimjas/vim-python-pep8-indent'
  use {'ahmedkhalf/jupyter-nvim', run = ":UpdateRemotePlugins"}
  use { 'dccsillag/magma-nvim', run = ':UpdateRemotePlugins' }

  -- Markdown preview
  use {'iamcco/markdown-preview.nvim', run=':call mkdp#util#install()'}

  -- Tests
  use {"rcarriga/vim-ultest", requires = {"janko/vim-test"}, run = ":UpdateRemotePlugins"}

  -- Diffview
  use 'sindrets/diffview.nvim'

  -- Manage tab settings
  use 'tpope/vim-sleuth'

  -- Which key
  use "folke/which-key.nvim"

  -- Terminal
  use 'akinsho/nvim-toggleterm.lua'

  -- rsync
  use 'kenn7/vim-arsync'
  -- check: https://github.com/chipsenkbeil/distant.nvim

  -- Quickfix
  use 'kevinhwang91/nvim-bqf'
  use 'gabrielpoca/replacer.nvim'

  -- Refactoring
  -- use { "ThePrimeagen/refactoring.nvim",
  --   requires = {
  --     {"nvim-lua/plenary.nvim"},
  --     {"nvim-treesitter/nvim-treesitter"}
  --   }
  -- }

end,

config = {
  profile = {
    enable = true,
    threshold = 1,
  }
}

})

