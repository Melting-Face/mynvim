vim.opt.rtp:prepend(vim.fn.getcwd())
-- navic: document symbol을 지원하는 서버가 한 버퍼에 둘 이상 붙어도 처음 붙은 서버 하나만 연결한다
-- (두 번째 서버를 attach하면 navic이 "Already attached" 경고를 띄움)
local attached = {}
package.loaded["nvim-navic"] = {
  attach = function(client, bufnr)
    table.insert(attached, client.name)
    vim.b[bufnr].navic_client_id = client.id
    vim.b[bufnr].navic_client_name = client.name
  end,
}
package.loaded["cmp_nvim_lsp"] = {
  default_capabilities = function()
    return {}
  end,
}
package.loaded["mason-lspconfig"] = { setup = function() end }

local spec
for _, entry in ipairs(dofile("lua/plugins/lsp.lua")) do
  if type(entry) == "table" and entry[1] == "mason-org/mason-lspconfig.nvim" then
    spec = entry
  end
end
assert(spec, "mason-lspconfig 스펙이 없음")
spec.config(nil, spec.opts)

local clients = {
  [1] = { id = 1, name = "yamlls", server_capabilities = { documentSymbolProvider = true } },
  [2] = { id = 2, name = "docker_compose_language_service", server_capabilities = { documentSymbolProvider = true } },
  [3] = { id = 3, name = "null-ls", server_capabilities = {} },
}
vim.lsp.get_client_by_id = function(id)
  return clients[id]
end

local buf = vim.api.nvim_get_current_buf()
for id = 1, 3 do
  vim.api.nvim_exec_autocmds("LspAttach", { buffer = buf, data = { client_id = id } })
end
assert(#attached == 1 and attached[1] == "yamlls", "navic 연결: " .. table.concat(attached, ","))
os.exit(0)
