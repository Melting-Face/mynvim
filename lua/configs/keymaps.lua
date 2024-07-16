-- keymap can use string | function
-----------------------------------
local wk = require("which-key")

-- INFO: <leader> key (normal)
wk.add({
  { "<leader>hp", "<cmd>cexpr system('refurb --quiet .') | copen<cr>", desc="refurb dir" },
  { "<leader>tc", "<cmd>tabclose<CR>",                                 desc="tab close" },
})

-- INFO: <space> key
wk.add({
  { "<space>ba", "<cmd>bufdo bd<CR>", desc="buffer delete all" },
  { "<space>bx", "<cmd>bdelete<CR>",  desc="buffer close" },
  { "<space>tn", "<cmd>tabnew<CR>",   desc="new tab" },
  { "<space>tx", "<cmd>tabclose<CR>", desc="tab close" },
})

-- INFO: '[' key
wk.add({
  { "[b", "<cmd>bp<cr>",      desc="buffer previous" },
  { "[t", "<cmd>tabprev<CR>", desc="tab previous" },
})

-- INFO: ']' key
wk.add({
  { "]b", "<cmd>bn<cr>",      desc="buffer next" },
  { "]t", "<cmd>tabnext<CR>", desc="tab next" },
})

-- INFO: For wrap
vim.keymap.set("n", "j", '"gj"', { expr = true })
vim.keymap.set("n", "k", '"gk"', { expr = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  end,
})
