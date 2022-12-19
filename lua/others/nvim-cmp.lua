local cmp = require'cmp'
local navic = require'nvim-navic'
local lspconfig = require'lspconfig'

local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
end

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = "neorg" },
    { name = "crates" },
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup lspconfig.
local capabilities = require'cmp_nvim_lsp'.default_capabilities()
local languages = {
  'bashls',
  'dockerls',
  'gopls',
  'jdtls',
  'jsonls',
  'pyright',
  'rust_analyzer',
  'sumneko_lua',
  'sqlls',
  'tsserver',
  'vimls',
  'yamlls',
}

for _, language in ipairs(languages) do
  if language == 'sumneko_lua' then
    lspconfig[language].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          completion = {
            callSnippet = "Replace"
          },
          diagnostics = {
            globals = {
              'vim'
            },
          },
        },
      },
    }
  elseif language == 'pyright' then
    lspconfig[language].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        python = {
          analysis = {
            diagnosticMode = 'openFilesOnly',
            useLibraryCodeForTypes = false,
          },
        },
      },
    }
  else
    lspconfig[language].setup {
      on_attach = on_attach,
      capabilities = capabilities
    }
  end
end
