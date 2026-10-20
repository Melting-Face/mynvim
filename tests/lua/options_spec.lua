vim.opt.rtp:prepend(vim.fn.getcwd())
require("configs.options")
assert(vim.o.undofile, "undofile이 켜져 있어야 함")
assert(vim.o.fileencodings == "ucs-bom,utf-8,cp949,latin1", vim.o.fileencodings)
assert(not vim.o.cindent and not vim.o.smartindent, "indent는 filetype/treesitter에 맡김")
-- cp949 파일은 cp949로, ASCII 파일은 utf-8로 열려야 함
local cp949 = vim.fn.tempname()
vim.fn.writefile({ vim.iconv("한글", "utf-8", "cp949") }, cp949, "b")
vim.cmd.edit(cp949)
assert(vim.bo.fileencoding == "cp949" and vim.api.nvim_get_current_line() == "한글", vim.bo.fileencoding)
local ascii = vim.fn.tempname()
vim.fn.writefile({ "abc" }, ascii)
vim.cmd.edit(ascii)
assert(vim.bo.fileencoding == "utf-8", vim.bo.fileencoding)
assert(vim.o.undodir:find(vim.fn.stdpath("state") .. "/undo", 1, true) == 1)
assert(vim.fn.isdirectory(vim.fn.stdpath("state") .. "/undo") == 1)
if vim.fn.has("win32") == 1 then
  assert(vim.o.shell:match("pwsh") or vim.o.shell:match("powershell"))
elseif vim.fn.executable("zsh") == 1 then
  assert(vim.o.shell == "zsh")
end
os.exit(0)
