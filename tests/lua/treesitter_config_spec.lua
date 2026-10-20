vim.opt.rtp:prepend(vim.fn.getcwd())
-- nvim-treesitter 설정: 설치 스크립트와 CI(headless)에서는 파서를 동기로 설치하고,
-- 화면이 있는 일반 실행에서는 비동기로 설치해 UI를 멈추지 않는다
local captured
package.loaded["nvim-treesitter.configs"] = {
  setup = function(opts)
    captured = opts
  end,
}
package.loaded["nvim-treesitter.install"] = {}

local spec
for _, entry in ipairs(dofile("lua/plugins/treesitter.lua")) do
  if type(entry) == "table" and entry[1] == "nvim-treesitter/nvim-treesitter" then
    spec = entry
  end
end
assert(spec, "nvim-treesitter 스펙이 없음")

spec.config()
assert(captured.highlight.enable, "하이라이트가 켜져 있어야 함")
assert(captured.sync_install == true, "headless에서는 동기 설치여야 함")

local original_list_uis = vim.api.nvim_list_uis
vim.api.nvim_list_uis = function()
  return { {} }
end
spec.config()
vim.api.nvim_list_uis = original_list_uis
assert(captured.sync_install == false, "UI가 있으면 비동기 설치여야 함")
os.exit(0)
