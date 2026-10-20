vim.opt.rtp:prepend(vim.fn.getcwd())
-- ftplugin/java.lua: jdtls가 없으면 start_or_attach를 부르지 않고 WARN 안내만 한다
local started = 0
package.loaded["jdtls"] = {
  start_or_attach = function()
    started = started + 1
  end,
}
local notes = {}
vim.notify_once = function(msg, level)
  table.insert(notes, { msg = msg, level = level })
  return true
end

vim.fn.executable = function()
  return 0
end
dofile("ftplugin/java.lua")
assert(started == 0, "jdtls가 없는데 start_or_attach가 호출됨")
assert(#notes == 1, "안내가 한 번 있어야 함")
assert(notes[1].level == vim.log.levels.WARN, "WARN 수준이어야 함")
assert(notes[1].msg:find("jdtls", 1, true), "안내에 jdtls가 있어야 함")

-- mason 경로는 모두 configs.paths.mason_package로 만들어야 한다
local paths = require("configs.paths")
local original_mason_package = paths.mason_package
local requested = {}
paths.mason_package = function(name)
  table.insert(requested, name)
  return original_mason_package(name)
end

vim.fn.executable = function()
  return 1
end
dofile("ftplugin/java.lua")
assert(started == 1, "jdtls가 있으면 start_or_attach가 호출되어야 함")
local joined = table.concat(requested, ",")
assert(
  joined == "jdtls,java-debug-adapter,java-test",
  "mason 경로를 paths.mason_package로 만들어야 함: " .. joined
)
paths.mason_package = original_mason_package

-- jdtls 실행 파일: Windows는 mason이 만드는 packages/jdtls/jdtls.cmd 래퍼
-- (bin/jdtls.bat는 끝에 pause가 있어 LSP로 쓸 수 없음), 그 밖의 OS는 bin/jdtls
local last_config
package.loaded["jdtls"].start_or_attach = function(config)
  last_config = config
end
local original_is_windows = paths.is_windows
for _, case in ipairs({
  { windows = true, suffix = "/jdtls/jdtls.cmd" },
  { windows = false, suffix = "/jdtls/bin/jdtls" },
}) do
  paths.is_windows = function()
    return case.windows
  end
  last_config = nil
  dofile("ftplugin/java.lua")
  local cmd = last_config and last_config.cmd[1] or ""
  assert(cmd:sub(-#case.suffix) == case.suffix, "windows=" .. tostring(case.windows) .. " cmd=" .. cmd)
end
paths.is_windows = original_is_windows
os.exit(0)
