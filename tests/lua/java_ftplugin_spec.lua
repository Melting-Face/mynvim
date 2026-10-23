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

-- java -version 결과를 흉내 낸다 (기본은 jdtls가 요구하는 Java 25)
local java_version_output = 'openjdk version "25.0.4" 2026-07-21'
local system_calls = {}
vim.system = function(cmd)
  table.insert(system_calls, cmd)
  return {
    wait = function()
      return { code = 0, stdout = "", stderr = java_version_output }
    end,
  }
end
vim.env.JAVA_HOME = nil

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

-- jdtls 1.62부터 Java 25가 있어야 실행된다: 25 미만이면 시작하지 않고 원인과 해결법을 WARN으로 안내
for _, case in ipairs({
  { output = 'openjdk version "21.0.12.1" 2026-07-21 LTS', start = false },
  { output = 'java version "1.8.0_401"', start = false },
  { output = 'openjdk version "25" 2025-09-16', start = true },
  { output = 'openjdk version "27.0.1" 2027-01-19', start = true },
}) do
  java_version_output = case.output
  vim.g.jdtls_java_major = nil
  started, notes = 0, {}
  package.loaded["jdtls"].start_or_attach = function()
    started = started + 1
  end
  dofile("ftplugin/java.lua")
  assert((started == 1) == case.start, case.output .. ": started=" .. started)
  local java_notes = vim.tbl_filter(function(n)
    return n.msg:find("Java 25", 1, true) ~= nil
  end, notes)
  if case.start then
    assert(#java_notes == 0, case.output .. ": 25 이상인데 안내가 나옴")
  else
    assert(#java_notes == 1 and java_notes[1].level == vim.log.levels.WARN, case.output .. ": Java 25 안내가 없음")
    assert(java_notes[1].msg:find("JAVA_HOME", 1, true), "안내에 JAVA_HOME 확인 방법이 있어야 함")
  end
end

-- 버전은 세션에서 한 번만 확인한다 (Java 파일을 열 때마다 java를 실행하지 않음)
java_version_output = 'openjdk version "25.0.4" 2026-07-21'
vim.g.jdtls_java_major = nil
system_calls = {}
dofile("ftplugin/java.lua")
dofile("ftplugin/java.lua")
assert(#system_calls == 1, "java -version 호출 횟수: " .. #system_calls)

-- jdtls 래퍼처럼 JAVA_HOME/bin/java가 있으면 그것을 검사한다
local java_home = vim.fn.tempname()
local java_exe = java_home .. "/bin/java" .. (paths.is_windows() and ".exe" or "")
vim.fn.mkdir(java_home .. "/bin", "p")
vim.fn.writefile({}, java_exe)
vim.env.JAVA_HOME = java_home
vim.g.jdtls_java_major = nil
system_calls = {}
dofile("ftplugin/java.lua")
assert(
  system_calls[1] and system_calls[1][1] == java_exe,
  "JAVA_HOME의 java를 써야 함: " .. vim.inspect(system_calls[1])
)
vim.env.JAVA_HOME = nil
vim.fn.delete(java_home, "rf")

-- 위 버전 검사가 start_or_attach를 바꿔 두었으므로 config를 기록하는 함수로 되돌린다
package.loaded["jdtls"].start_or_attach = function(config)
  last_config = config
end
-- 디버그·테스트 번들: 설치되지 않았으면 빈 목록(빈 문자열이 jdtls에 넘어가지 않게)과 WARN 안내 1회
-- java-test의 runner, jacoco jar는 OSGi 번들이 아니므로 제외한다 (nvim-jdtls README)
local original_glob = vim.fn.glob
local globbed = {}
vim.fn.glob = function(pattern)
  for key, files in pairs(globbed) do
    if pattern:find(key, 1, true) then
      return files
    end
  end
  return {}
end
notes = {}
last_config = nil
dofile("ftplugin/java.lua")
assert(
  vim.deep_equal(last_config.init_options.bundles, {}),
  "번들이 없을 때: " .. vim.inspect(last_config.init_options.bundles)
)
local debug_notes = vim.tbl_filter(function(n)
  return n.msg:find("java-debug-adapter", 1, true) ~= nil
end, notes)
assert(
  #debug_notes == 1 and debug_notes[1].level == vim.log.levels.WARN,
  "java-debug-adapter 미설치 안내가 없음"
)

local debug_jar = "/m/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-0.53.2.jar"
local test_jar = "/m/java-test/extension/server/com.microsoft.java.test.plugin-0.43.1.jar"
globbed = {
  ["java-debug-adapter"] = { debug_jar },
  ["java-test"] = {
    test_jar,
    "/m/java-test/extension/server/com.microsoft.java.test.runner-jar-with-dependencies.jar",
    "/m/java-test/extension/server/jacocoagent.jar",
  },
}
dofile("ftplugin/java.lua")
assert(
  vim.deep_equal(last_config.init_options.bundles, { debug_jar, test_jar }),
  "번들: " .. vim.inspect(last_config.init_options.bundles)
)
vim.fn.glob = original_glob
os.exit(0)
