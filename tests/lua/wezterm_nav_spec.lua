vim.opt.rtp:prepend(vim.fn.getcwd())
-- nvim 창과 WezTerm 패널을 같은 키로 오가는 연동 검사 (wezterm cli 호출은 기록만 한다)
local nav = require("configs.wezterm_nav")
local calls = {}
nav.cli = function(args)
  table.insert(calls, table.concat(args, " "))
end

-- WezTerm 밖(WEZTERM_PANE 없음): 창 하나여도 wezterm cli를 부르지 않는다
vim.env.WEZTERM_PANE = nil
nav.navigate("h")
nav.resize("l")
assert(#calls == 0, "WezTerm 밖에서 cli 호출됨")

-- nvim 창 끝에서는 WezTerm 패널로 넘어간다
vim.env.WEZTERM_PANE = "0"
nav.navigate("l")
assert(calls[1] == "activate-pane-direction Right", tostring(calls[1]))
nav.resize("j")
assert(calls[2] == "adjust-pane-size --amount 2 Down", tostring(calls[2]))

-- nvim 창이 나뉘어 있으면 nvim 안에서 처리한다
vim.cmd("vsplit")
local before = vim.api.nvim_get_current_win()
nav.navigate("l")
assert(vim.api.nvim_get_current_win() ~= before, "nvim 창 이동 안 됨")
assert(#calls == 2, "nvim 창이 있는데 cli 호출됨")
local width = vim.api.nvim_win_get_width(0)
nav.resize("h")
assert(vim.api.nvim_win_get_width(0) ~= width, "nvim 창 크기 조절 안 됨")
assert(#calls == 2, "nvim 창이 있는데 cli 호출됨")

-- setup: 키 매핑과 autocmd (일시 중지·종료 때 IS_NVIM을 지운다)
nav.setup()
for _, lhs in ipairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>", "<A-h>", "<A-j>", "<A-k>", "<A-l>" }) do
  assert(vim.fn.maparg(lhs, "n") ~= "", lhs .. " 매핑 없음")
end
for _, event in ipairs({ "VimEnter", "VimResume", "VimLeavePre", "VimSuspend" }) do
  assert(#vim.api.nvim_get_autocmds({ group = "WeztermNav", event = event }) == 1, event .. " autocmd 없음")
end
os.exit(0)
