local paths = require("configs.paths")
local mason = vim.fn.stdpath("data") .. "/mason/packages"
local jdtls_path = paths.mason_package("jdtls")
-- Windows에서는 jdtls.cmd 래퍼를 사용한다
local jdtls_bin = paths.is_windows() and "jdtls.cmd" or "jdtls"

local jdtls = require("jdtls")

local config = {
  cmd = { jdtls_path .. "/bin/" .. jdtls_bin },
  root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]),
}

local bundles = {
  vim.fn.glob(mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(mason .. "/java-test/extension/server/*.jar", 1), "\n"))

config["init_options"] = {
  bundles = bundles,
}
jdtls.start_or_attach(config)
