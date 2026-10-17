local M = {}

local function default_executable(name)
  return vim.fn.executable(name) == 1
end

-- 설치된 런타임에 맞는 language server 목록 (java/cargo 없으면 관련 서버 제외)
function M.list(executable)
  executable = executable or default_executable
  local has_java = executable("java")
  local has_cargo = executable("cargo")

  local servers = {
    "bashls",
    "dockerls",
    "docker_compose_language_service",
    "eslint",
  }
  if has_java then
    table.insert(servers, "gradle_ls")
  end
  table.insert(servers, "helm_ls")
  if has_java then
    table.insert(servers, "jdtls")
  end
  vim.list_extend(servers, { "jsonls", "lua_ls", "prismals", "pyright", "ruff" })
  if has_cargo then
    table.insert(servers, "rust_analyzer")
  end
  vim.list_extend(servers, { "terraformls", "taplo", "ts_ls", "yamlls" })
  return servers
end

return M
