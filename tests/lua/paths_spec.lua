vim.opt.rtp:prepend(vim.fn.getcwd())
local paths = require("configs.paths")
assert(paths.mason_package("jdtls") == vim.fn.stdpath("data") .. "/mason/packages/jdtls")
assert(paths.is_windows() == (vim.fn.has("win32") == 1))
if paths.is_windows() then assert(paths.exe("a/codelldb") == "a/codelldb.exe")
else assert(paths.exe("a/codelldb") == "a/codelldb") end
os.exit(0)
