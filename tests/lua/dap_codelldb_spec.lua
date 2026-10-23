vim.opt.rtp:prepend(vim.fn.getcwd())
-- codelldb 어댑터 실행 파일: mason 패키지의 extension/adapter/codelldb(.exe)
local paths = require("configs.paths")
paths.mason_package = function(name)
  return "/mason/" .. name
end

local dap = {
  adapters = {},
  configurations = {},
  listeners = { after = { event_initialized = {} }, before = { event_terminated = {}, event_exited = {} } },
}
package.loaded["dap"] = dap
package.loaded["dapui"] = { setup = function() end, open = function() end, close = function() end }

local spec
for _, entry in ipairs(dofile("lua/plugins/dap.lua")) do
  if type(entry) == "table" and entry[1] == "rcarriga/nvim-dap-ui" then
    spec = entry
  end
end
assert(spec, "nvim-dap-ui 스펙이 없음")

for _, case in ipairs({
  { windows = false, command = "/mason/codelldb/extension/adapter/codelldb" },
  { windows = true, command = "/mason/codelldb/extension/adapter/codelldb.exe" },
}) do
  paths.is_windows = function()
    return case.windows
  end
  spec.config()
  local command = dap.adapters.codelldb and dap.adapters.codelldb.command
  assert(command == case.command, "windows=" .. tostring(case.windows) .. " command=" .. tostring(command))
end
os.exit(0)
