vim.opt.rtp:prepend(vim.fn.getcwd())
local servers = require("configs.lsp_servers")
local none = servers.list(function() return false end)
assert(not vim.tbl_contains(none, "jdtls"))
assert(not vim.tbl_contains(none, "gradle_ls"))
assert(not vim.tbl_contains(none, "rust_analyzer"))
assert(vim.tbl_contains(none, "lua_ls") and vim.tbl_contains(none, "pyright"))
local all = servers.list(function() return true end)
assert(vim.tbl_contains(all, "jdtls") and vim.tbl_contains(all, "gradle_ls") and vim.tbl_contains(all, "rust_analyzer"))
local java_only = servers.list(function(n) return n == "java" end)
assert(vim.tbl_contains(java_only, "jdtls") and not vim.tbl_contains(java_only, "rust_analyzer"))
-- ruff server는 ruff-lsp의 args를 지원하지 않으므로 lint 설정으로 규칙을 넘긴다
local ruff = servers.settings.ruff.init_options.settings
assert(ruff.args == nil, "ruff server는 args를 지원하지 않음")
assert(vim.tbl_contains(ruff.lint.extendSelect, "B") and vim.tbl_contains(ruff.lint.extendSelect, "PD"))
assert(vim.deep_equal(ruff.lint.ignore, { "PD901" }))
assert(servers.settings.lua_ls.settings.Lua.diagnostics.globals[1] == "vim")
-- 전용 플러그인이 띄우는 서버와 none-ls와 겹치는 서버는 자동 활성화에서 제외
for _, name in ipairs({ "jdtls", "rust_analyzer", "stylua" }) do
  assert(vim.tbl_contains(servers.automatic_enable_exclude, name), name)
end
os.exit(0)
