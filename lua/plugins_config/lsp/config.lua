local language_servers = require('plugins_config.lsp.servers')

local opts = {noremap=true, silent=true}
local aerial = require('aerial')


--           on attach
-- ──────────────────────────────
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Aerial window
  aerial.on_attach(client)
  vim.api.nvim_buf_set_keymap(0, 'n', '<leader>a', '<cmd>AerialToggle<CR>', {})

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Get/Go
  -- See telescope for definition and references
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

  -- Information
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  -- Workspace
  buf_set_keymap('n', '<Leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<Leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<Leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

  -- Code actions
  buf_set_keymap('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

  -- Diagnostics
  buf_set_keymap('n', '<Leader>cdl', "<cmd>lua vim.diagnostic.open_float(0, {scope='line'})<CR>", opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<leader>cf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<leader>cf", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  -- Telescope LSP
  local function buf_bind_picker(...)
    require('plugins_config.utils').buf_bind_picker(bufnr, ...)
  end
  buf_bind_picker('<Leader>fs', 'lsp_document_symbols')
  buf_bind_picker('<Leader>fS', 'lsp_workspace_symbols')
  buf_bind_picker('<Leader>fd', 'lsp_document_diagnostics')
  buf_bind_picker('<Leader>fD', 'lsp_workspace_diagnostics')
  buf_bind_picker('gd', 'lsp_definitions')
  buf_bind_picker('gr', 'lsp_references')

end


--           handlers
-- ──────────────────────────────
vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(
    vim.lsp.handlers.hover,
    {
      border = "rounded"
    }
  )

vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {
     border = "rounded"
    }
  )


--          diagnostics
-- ──────────────────────────────
vim.fn.sign_define('DiagnosticSignError',
    { text = '☓', texthl = 'DiagnosticSignError' })

vim.fn.sign_define('DiagnosticSignWarn',
    { text = '', texthl = 'DiagnosticSignWarn' })

vim.fn.sign_define('DiagnosticSignInfo',
    { text = '', texthl = 'DiagnosticSignInfo' })

vim.fn.sign_define('DiagnosticSignHint',
    { text = '', texthl = 'DiagnosticSignHint' })

vim.diagnostic.config({
  underline = true,
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  severity_sort = false,
  float = {
    show_header = true,
    border = 'rounded',
    format = function (diagnostic)
      return string.format("%s (%s)", diagnostic.message, diagnostic.source)
    end,
  },
})


--        language servers
-- ──────────────────────────────
-- additional capabilities for autocompletion with nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(
  capabilities,
  {
    snippetSupport = true,
  }
)

-- obtain the cwd for conditional registering
local lsputil = require("lspconfig.util")
local cwd = vim.loop.cwd()
local project_nvim = require('project_nvim.project')
if project_nvim ~= nil then
  cwd = project_nvim.find_pattern_root() or vim.loop.cwd()
end

-- Language servers to register
local server_names = {
  'null-ls',
  'sumneko_lua',
  'dockerls',
  'jsonls',
}

-- register pyright if the config file exists, otherwise use jedi_language_server
if lsputil.path.exists(lsputil.path.join(cwd, "pyrightconfig.json")) then
  table.insert(server_names, 'pyright')
else
  table.insert(server_names, 'jedi_language_server')
end

-- common language server options
local common_lang_options = {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = require('project_nvim.project').find_pattern_root,
  flags = {
    debounce_text_changes = 200,
  },
}

-- Register servers
language_servers.register(server_names, common_lang_options)


--            nvim-cmp
-- ──────────────────────────────
vim.o.completeopt = "menuone,noselect"

local cmp = require('cmp')

-- luasnip supertab helpers
local luasnip = require("luasnip")

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body)
    end
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-h>'] = cmp.mapping.scroll_docs(-4),
    ['<C-l>'] = cmp.mapping.scroll_docs(4),

    -- Toggle completion menu with <C-Space>
    ['<C-Space>'] = cmp.mapping(function (fallback)
      local action
      if not cmp.visible() then
        action = cmp.complete
      else
        action = cmp.close
      end

      if not action() then
        fallback()
      end
    end),

    ['<C-e>'] = cmp.mapping.close(),

    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {'i', 's'}),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {'i', 's'}),
  },

  -- TODO: disable buffer source in really big files
  sources = {
    {name = 'nvim_lsp'},
    {name = 'buffer'},
    {name = 'path'},
    {name = 'luasnip'},
  },

  formatting = {
    format = require('lspkind').cmp_format({with_text = false, menu = ({
      nvim_lsp = '()',
      buffer = '()',
      path = '(/)',
      nvim_lua = '()',
    })}),
  },

  documentation = {
    border = 'rounded',
  },

})

vim.api.nvim_exec(
  "augroup CmpLuaFiletype " ..
  "autocmd FileType lua lua require('cmp').setup.buffer{" ..
    "sources = {" ..
      "{name = 'nvim_lsp}', {name = 'nvim_lua'}, {name = 'buffer'}, {name = 'path'}, {name = 'luasnip'}" ..
    "}" ..
  "}" ..
  "augroup END",
  false
)


-- autopairs support
require("nvim-autopairs.completion.cmp").setup({
  map_cr = true,
  map_complete = true,
  auto_select = false,
  insert = false,
})

