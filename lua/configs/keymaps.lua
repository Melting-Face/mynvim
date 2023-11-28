-- keymap can use string | function
-----------------------------------
local wk = require("which-key")

-- INFO: <leader> key (normal)
wk.register({
  h = {
    p = { "<cmd>cexpr system('refurb --quiet .') | copen<cr>", "refurb dir" },
  },
  t = {
    name = "tab & toggle",
    c = { "<cmd>tabclose<CR>", "tab close" },
  },
}, {
  prefix = "<leader>",
})

-- INFO: <space> key
wk.register({
  b = {
    name = "buffer",
    a = { "<cmd>bufdo bd<CR>", "buffer delete all" },
    x = { "<cmd>bdelete<CR>", "buffer close" },
  },
  t = {
    name = "tab",
    n = { "<cmd>tabnew<CR>", "new tab" },
    x = { "<cmd>tabclose<CR>", "tab close" },
  },
}, {
  prefix = "<space>",
})

-- INFO: '[' key
wk.register({
  b = { "<cmd>bp<cr>", "buffer previous" },
  t = { "<cmd>tabprev<CR>", "tab previous" },
}, {
  prefix = "[",
})

-- INFO: ']' key
wk.register({
  b = { "<cmd>bn<cr>", "buffer next" },
  t = { "<cmd>tabnext<CR>", "tab next" },
}, {
  prefix = "]",
})

-- INFO: For wrap
vim.keymap.set("n", "j", '"gj"', { expr = true })
vim.keymap.set("n", "k", '"gk"', { expr = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set('n', "K", vim.lsp.buf.hover, opts)
    vim.keymap.set('n', "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', "<space>q", vim.diagnostic.setloclist, opts)
    vim.keymap.set('n', "gr", vim.lsp.buf.references, opts)
    vim.keymap.set({ 'n', 'v' }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  end,
})
