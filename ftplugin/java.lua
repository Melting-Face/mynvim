local paths = require("configs.paths")
local jdtls_path = paths.mason_package("jdtls")
-- Windows에서는 mason이 만드는 jdtls.cmd 래퍼를 사용한다 (bin/jdtls.bat는 끝에 pause가 있어 LSP로 쓸 수 없음)
local jdtls_cmd = paths.is_windows() and (jdtls_path .. "/jdtls.cmd") or (jdtls_path .. "/bin/jdtls")

local config = {
  cmd = { jdtls_cmd },
  root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]),
}

-- jdtls가 아직 설치되지 않았으면 LSP를 시작하지 않고 한 번만 안내한다
if vim.fn.executable(config.cmd[1]) ~= 1 then
  vim.notify_once(
    "jdtls를 찾을 수 없어 Java LSP를 시작하지 않습니다 (:MasonInstall jdtls 로 설치하세요): "
      .. config.cmd[1],
    vim.log.levels.WARN
  )
  return
end

-- jdtls 1.62부터 Java 25가 있어야 실행된다 (낮으면 시작 직후 종료되므로 시작하지 않고 안내한다)
-- jdtls 래퍼처럼 JAVA_HOME/bin/java가 있으면 그것을, 없으면 PATH의 java를 검사하고 결과는 세션 동안 기억한다
if vim.g.jdtls_java_major == nil then
  local java = "java"
  if vim.env.JAVA_HOME then
    local candidate = vim.env.JAVA_HOME .. "/bin/java" .. (paths.is_windows() and ".exe" or "")
    if vim.uv.fs_stat(candidate) then
      java = candidate
    end
  end
  local ok, result = pcall(function()
    return vim.system({ java, "-version" }, { text = true }):wait()
  end)
  local output = ok and ((result.stderr or "") .. (result.stdout or "")) or ""
  vim.g.jdtls_java = java
  vim.g.jdtls_java_major = tonumber(output:match('version "(%d+)')) or 0
end
if vim.g.jdtls_java_major < 25 then
  local found = vim.g.jdtls_java_major > 0 and ("Java " .. vim.g.jdtls_java_major) or "버전을 확인할 수 없음"
  vim.notify_once(
    "jdtls는 Java 25 이상에서만 실행되어 Java LSP를 시작하지 않습니다 ("
      .. vim.g.jdtls_java
      .. ": "
      .. found
      .. "). JDK 25를 설치하고, JAVA_HOME을 쓴다면 JDK 25 경로로 바꾸세요",
    vim.log.levels.WARN
  )
  return
end

local jdtls = require("jdtls")

-- mason 경로는 모두 configs.paths를 통해 만든다
local debug_server = paths.mason_package("java-debug-adapter") .. "/extension/server"
local test_server = paths.mason_package("java-test") .. "/extension/server"
-- 번들이 설치되지 않았으면 빈 목록으로 둔다 (glob을 목록으로 받아 빈 문자열이 jdtls에 넘어가지 않게 함)
local bundles = vim.fn.glob(debug_server .. "/com.microsoft.java.debug.plugin-*.jar", true, true)
if #bundles == 0 then
  vim.notify_once(
    "java-debug-adapter가 없어 Java 디버깅을 쓸 수 없습니다"
      .. " (설치 중이면 잠시 후 다시 열고, 계속되면 :MasonInstall java-debug-adapter java-test)",
    vim.log.levels.WARN
  )
end
-- java-test의 runner, jacoco jar는 OSGi 번들이 아니므로 제외한다 (nvim-jdtls README)
local excluded = { "com.microsoft.java.test.runner-jar-with-dependencies.jar", "jacocoagent.jar" }
for _, jar in ipairs(vim.fn.glob(test_server .. "/*.jar", true, true)) do
  if not vim.tbl_contains(excluded, vim.fn.fnamemodify(jar, ":t")) then
    table.insert(bundles, jar)
  end
end

config["init_options"] = {
  bundles = bundles,
}
jdtls.start_or_attach(config)
