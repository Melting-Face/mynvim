vim.opt.rtp:prepend(vim.fn.getcwd())
require("configs.options")
assert(vim.o.undodir:find(vim.fn.stdpath("state") .. "/undo", 1, true) == 1)
assert(vim.fn.isdirectory(vim.fn.stdpath("state") .. "/undo") == 1)
if vim.fn.has("win32") == 1 then assert(vim.o.shell:match("pwsh") or vim.o.shell:match("powershell"))
elseif vim.fn.executable("zsh") == 1 then assert(vim.o.shell == "zsh") end
os.exit(0)
