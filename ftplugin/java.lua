local paths = require("configs.paths")
local mason = vim.fn.stdpath("data") .. "/mason/packages"
local jdtls_path = paths.mason_package("jdtls")
-- Windows에서는 jdtls.cmd 래퍼를 사용한다
local jdtls_bin = paths.is_windows() and "jdtls.cmd" or "jdtls"

local config = {
  cmd = { jdtls_path .. "/bin/" .. jdtls_bin },
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

local bundles = {
  vim.fn.glob(mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(mason .. "/java-test/extension/server/*.jar", 1), "\n"))

config["init_options"] = {
  bundles = bundles,
}
jdtls.start_or_attach(config)
