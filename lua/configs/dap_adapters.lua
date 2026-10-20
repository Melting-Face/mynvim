local M = {}

local function default_executable(name)
  return vim.fn.executable(name) == 1
end

-- mason-nvim-dap으로 설치할 디버그 어댑터 목록 (java가 없으면 Java 어댑터 제외)
-- python: debugpy, codelldb: C/C++/Rust, javadbg/javatest: java-debug-adapter/java-test
function M.list(executable)
  executable = executable or default_executable
  local adapters = { "python", "codelldb" }
  if executable("java") then
    vim.list_extend(adapters, { "javadbg", "javatest" })
  end
  return adapters
end

return M
