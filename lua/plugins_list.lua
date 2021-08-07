local execute = vim.api.nvim_command
local fn = vim.fn

-- If Packer is not installed, download and install it
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
  execute 'packadd packer.nvim'
end

return require('packer').startup({function()
  -- Packer
  use {'wbthomason/packer.nvim'}

  -- Icons
  use 'kyazdani42/nvim-web-devicons'

  -- Colors
  use 'norcalli/nvim-colorizer.lua'
  use 'folke/tokyonight.nvim'

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-compe'
  use 'kabouzeid/nvim-lspinstall'
  use 'onsails/lspkind-nvim'
  use {'folke/lsp-trouble.nvim', requires = "kyazdani42/nvim-web-devicons"}
  use {'jose-elias-alvarez/null-ls.nvim', requires = {"nvim-lua/plenary.nvim", "neovim/nvim-lspconfig"}}

  -- Syntax
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- Smooth scrolling
  use 'karb94/neoscroll.nvim'

  -- Fuzzy finding
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
  use 'nvim-telescope/telescope-fzy-native.nvim'
  use 'nvim-telescope/telescope-project.nvim'

  -- Tabs
  use 'romgrk/barbar.nvim'

  --Statusline
  use {'hoob3rt/lualine.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true}}

  -- File tree
  use {'kyazdani42/nvim-tree.lua', opt = true, cmd = {'NvimTreeToggle', 'NvimTreeFindFile'}}

  -- Indent lines
  use 'lukas-reineke/indent-blankline.nvim'

  -- Commenting
  use 'b3nj5m1n/kommentary'

  -- Autopairs
  use 'steelsojka/pears.nvim'

  -- Surround
  use 'tpope/vim-surround'

  -- Substitution
  use 'svermeulen/vim-subversive'

  -- Tmux navigation
  use 'aserowy/tmux.nvim'

  -- Git
  use 'lewis6991/gitsigns.nvim'
  use 'tpope/vim-fugitive'
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim'}

  -- Change cwd to project
  use 'airblade/vim-rooter'
  -- Look into https://github.com/ahmedkhalf/lsp-rooter.nvim

  -- Dashboard
  use 'glepnir/dashboard-nvim'

  -- Search
  use 'eugen0329/vim-esearch'

  -- Documentation generation
  use {'kkoomen/vim-doge', run=':call doge#install()', opt = true, cmd = {'DogeGenerate'}}

  -- Repeat
  use 'tpope/vim-repeat'

  -- Targets
  use 'wellle/targets.vim'

  -- Debugging
  use 'mfussenegger/nvim-dap'
  use 'Pocco81/DAPInstall.nvim'
  use {'rcarriga/nvim-dap-ui', requires = {'mfussenegger/nvim-dap'}}

  -- Python
  use 'Vimjas/vim-python-pep8-indent'
  use {'ahmedkhalf/jupyter-nvim', run = ":UpdateRemotePlugins"}

  -- Markdown preview
  use {'iamcco/markdown-preview.nvim', run=':call mkdp#util#install()'}

  -- Tests
  use {"rcarriga/vim-ultest", requires = {"janko/vim-test"}, run = ":UpdateRemotePlugins",
       opt = true, cmd = {'Ulttest', 'UltestNearest'}}

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

  -- Quickfix
  use 'kevinhwang91/nvim-bqf'
  use 'gabrielpoca/replacer.nvim'
end,

config = {
  profile = {
    enable = true,
    threshold = 1
  }
}

})

