local jdtls_path = MASON .. "/jdtls"
local workspace_path = HOME .. "/workspace/java/"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local project_path = workspace_path .. project_name

has_jdtls, jdtls = pcall(require, 'jdtls')
if has_jdtls == true then
  local bundles = {
    vim.fn.glob(MASON .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"),
  };

  vim.list_extend(bundles, vim.split(vim.fn.glob(MASON .. "/java-test/extension/server/*.jar"), "\n"))

  local config = {
     cmd = {
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xms1g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens",
      "java.base/java.util=ALL-UNNAMED",
      "--add-opens",
      "java.base/java.lang=ALL-UNNAMED",
      "-jar",
      vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
      "-configuration",
      jdtls_path .. "/config_" .. OS,
      "-data",
      project_path,
    },
    on_attach = function(client, bufnr)
      jdtls.setup_dap({
        hotcodereplace = 'auto'
      })
      require('jdtls.dap').setup_dap_main_class_configs()
    end,
    root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
    settings = {
    },
    init_options = {
      bundles = bundles,
    },
  }
  jdtls.start_or_attach(config)
end
