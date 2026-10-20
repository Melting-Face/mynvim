vim.opt.rtp:prepend(vim.fn.getcwd())
-- headless(설치 스크립트, CI, 테스트)에서는 LSP 서버와 포매터·린터 설치를 시작하지 않는다
-- (+qa로 끝나며 설치가 끊기면 mason이 반쪽 디렉터리를 설치됨으로 판단해 다시 설치하지 않음)
local function specs()
  local found = {}
  for _, entry in ipairs(dofile("lua/plugins/lsp.lua")) do
    if type(entry) == "table" then
      found[entry[1]] = entry
    end
  end
  return found
end
local function opts_of(spec)
  return type(spec.opts) == "function" and spec.opts(spec, {}) or spec.opts
end

local headless = specs()
assert(
  #opts_of(headless["mason-org/mason-lspconfig.nvim"]).ensure_installed == 0,
  "headless인데 LSP 설치 목록이 있음"
)
assert(
  opts_of(headless["jay-babu/mason-null-ls.nvim"]).automatic_installation == false,
  "headless인데 포매터 자동 설치가 켜져 있음"
)

local original_list_uis = vim.api.nvim_list_uis
vim.api.nvim_list_uis = function()
  return { {} }
end
local ui = specs()
vim.api.nvim_list_uis = original_list_uis
assert(
  vim.tbl_contains(opts_of(ui["mason-org/mason-lspconfig.nvim"]).ensure_installed, "lua_ls"),
  "일반 실행인데 lua_ls가 목록에 없음"
)
assert(
  opts_of(ui["jay-babu/mason-null-ls.nvim"]).automatic_installation == true,
  "일반 실행인데 포매터 자동 설치가 꺼져 있음"
)
os.exit(0)
