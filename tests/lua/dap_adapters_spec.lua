vim.opt.rtp:prepend(vim.fn.getcwd())
-- 디버그 어댑터 설치 목록 (mason-nvim-dap 이름): java가 있을 때만 Java 어댑터를 넣는다
local adapters = require("configs.dap_adapters")
assert(vim.deep_equal(
  adapters.list(function()
    return false
  end),
  { "python", "codelldb" }
))
local with_java = adapters.list(function(name)
  return name == "java"
end)
assert(vim.tbl_contains(with_java, "javadbg") and vim.tbl_contains(with_java, "javatest"), table.concat(with_java, ","))
os.exit(0)
