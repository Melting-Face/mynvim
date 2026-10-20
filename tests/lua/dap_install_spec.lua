vim.opt.rtp:prepend(vim.fn.getcwd())
-- headless(설치 스크립트, CI, 테스트)에서는 어댑터 설치를 시작하지 않는다
-- (+qa로 끝나며 설치가 끊기면 mason이 반쪽 디렉터리를 설치됨으로 판단해 다시 설치하지 않음)
local function mason_nvim_dap_spec()
  for _, entry in ipairs(dofile("lua/plugins/dap.lua")) do
    if type(entry) == "table" and entry[1] == "jay-babu/mason-nvim-dap.nvim" then
      return entry
    end
  end
end
local spec = mason_nvim_dap_spec()
assert(spec, "mason-nvim-dap 스펙이 없음")
local opts = type(spec.opts) == "function" and spec.opts(spec, {}) or spec.opts
assert(
  #opts.ensure_installed == 0,
  "headless인데 설치 목록이 있음: " .. table.concat(opts.ensure_installed, ",")
)

-- UI가 있는 일반 실행에서는 어댑터 목록을 설치한다
local original_list_uis = vim.api.nvim_list_uis
vim.api.nvim_list_uis = function()
  return { {} }
end
spec = mason_nvim_dap_spec()
opts = type(spec.opts) == "function" and spec.opts(spec, {}) or spec.opts
vim.api.nvim_list_uis = original_list_uis
assert(vim.tbl_contains(opts.ensure_installed, "python"), "일반 실행인데 python 어댑터가 목록에 없음")
os.exit(0)
