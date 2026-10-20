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
    "jdtls를 찾을 수 없어 Java LSP를 시작하지 않습니다 (:MasonInstall jdtls 로 설치하세요): " .. config.cmd[1],
    vim.log.levels.WARN
  )
  return
end

local jdtls = require("jdtls")

-- mason 경로는 모두 configs.paths를 통해 만든다
local debug_server = paths.mason_package("java-debug-adapter") .. "/extension/server"
local test_server = paths.mason_package("java-test") .. "/extension/server"
local bundles = {
  vim.fn.glob(debug_server .. "/com.microsoft.java.debug.plugin-*.jar", 1),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(test_server .. "/*.jar", 1), "\n"))

config["init_options"] = {
  bundles = bundles,
}
jdtls.start_or_attach(config)
