-- keymap can use string | function
-----------------------------------
local wk = require("which-key")

-- INFO: <leader> key (normal)
wk.add({
  { "<leader>hp", "<cmd>cexpr system('refurb --quiet .') | copen<cr>", desc="refurb dir" },
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

-- INFO: For wrap (횟수 없이 누르면 화면 줄, 5j처럼 횟수를 주면 실제 줄 단위로 이동)
vim.keymap.set("n", "j", [[v:count == 0 ? 'gj' : 'j']], { expr = true })
vim.keymap.set("n", "k", [[v:count == 0 ? 'gk' : 'k']], { expr = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)
    -- K(hover), grr(참조), grn(이름 바꾸기), gra(코드 액션)는 nvim 0.11 기본 키를 쓴다
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})
