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

-- vim.lsp.config로 넘기는 서버별 설정 (나머지 서버는 nvim-lspconfig 기본값 사용)
M.settings = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = {
            "vim",
          },
        },
      },
    },
  },
  pyright = {
    settings = {
      python = {
        analysis = {
          diagnosticMode = "openFilesOnly",
          typeCheckingMode = "off",
        },
      },
    },
  },
  -- ruff server 설정 형식: https://docs.astral.sh/ruff/editors/settings/
  ruff = {
    init_options = {
      settings = {
        lint = {
          extendSelect = {
            "AIR",
            "B",
            "C4",
            "C90",
            "E",
            "F",
            "FURB",
            "G",
            "I",
            "LOG",
            "NPY",
            "PD",
            "Q",
            "SIM",
            "T20",
            "UP",
          },
          ignore = { "PD901" },
        },
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          kubernetes = {
            "*config*.yml",
            "*deployment*.yml",
            "*secret*.yml",
            "*service*.yml",
            "*value*.yml",
          },
          ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = "*gitlab*.yml",
          ["https://raw.githubusercontent.com/dbt-labs/dbt-jsonschema/main/schemas/dbt_project.json"] = {
            "*dbt_project.yml",
            "*packages.yml",
            "*profiles.yml",
            "*schema.yml",
            "*source.yml",
            "*model.yml",
          },
        },
      },
    },
  },
}

-- mason-lspconfig가 자동으로 켜지 않을 서버
-- jdtls는 ftplugin/java.lua(nvim-jdtls), rust_analyzer는 rustaceanvim이 띄우고,
-- stylua와 sqruff는 none-ls 포매터·진단으로 쓴다 (LSP로도 켜면 포맷과 진단이 두 번 실행됨)
M.automatic_enable_exclude = { "jdtls", "rust_analyzer", "stylua", "sqruff" }

return M
