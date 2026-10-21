-- nvim 창과 WezTerm 패널을 같은 키로 오간다 (C-h/j/k/l 이동, A-h/j/k/l 크기 조절)
-- nvim 창 끝에서는 wezterm cli로 WezTerm 패널을 움직이고,
-- WezTerm 쪽(wezterm.lua)은 user var IS_NVIM을 보고 키를 nvim에 넘길지 정한다
local M = {}

local directions = { h = "Left", j = "Down", k = "Up", l = "Right" }

-- wezterm cli 실행 (비동기). 테스트에서 바꿔 끼운다
function M.cli(args)
  pcall(vim.system, vim.list_extend({ "wezterm", "cli" }, args))
end

-- WezTerm 패널 안에서 실행 중인지 (mux 서버가 패널 환경에 넣어 준다)
local function in_wezterm()
  return vim.env.WEZTERM_PANE ~= nil
end

-- 그 방향에 다른 nvim 창이 있는지
local function has_neighbor(dir)
  return vim.fn.winnr(dir) ~= vim.fn.winnr()
end

-- dir 방향 창으로 이동, 끝이면 WezTerm 패널로 이동
function M.navigate(dir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(dir)
  if vim.api.nvim_get_current_win() == win and in_wezterm() then
    M.cli({ "activate-pane-direction", directions[dir] })
  end
end

-- 창 경계를 dir 쪽으로 2칸 옮긴다. 그 축에 nvim 창이 하나뿐이면 WezTerm 패널 크기를 조절
function M.resize(dir)
  local vertical = dir == "h" or dir == "l"
  -- 오른쪽(아래)에 이웃이 있으면 현재 창의 오른쪽(아래) 경계를, 아니면 왼쪽(위) 경계를 옮긴다
  local after, before = "l", "h"
  if not vertical then
    after, before = "j", "k"
  end
  local grow = dir == "l" or dir == "j"
  local delta
  if has_neighbor(after) then
    delta = grow and "+2" or "-2"
  elseif has_neighbor(before) then
    delta = grow and "-2" or "+2"
  end
  if delta then
    vim.cmd((vertical and "vertical " or "") .. "resize " .. delta)
  elseif in_wezterm() then
    M.cli({ "adjust-pane-size", "--amount", "2", directions[dir] })
  end
end

-- OSC 1337 SetUserVar로 WezTerm에 값을 알린다 (빈 값이면 지움)
local function set_user_var(name, value)
  local encoded = value == "" and "" or vim.base64.encode(value)
  vim.api.nvim_chan_send(vim.v.stderr, "\027]1337;SetUserVar=" .. name .. "=" .. encoded .. "\007")
end

function M.setup()
  for key in pairs(directions) do
    vim.keymap.set("n", "<C-" .. key .. ">", function()
      M.navigate(key)
    end, { desc = "nvim 창, WezTerm 패널 사이 이동" })
    vim.keymap.set("n", "<A-" .. key .. ">", function()
      M.resize(key)
    end, { desc = "창 크기 조절" })
  end
  if not in_wezterm() then
    return
  end
  local group = vim.api.nvim_create_augroup("WeztermNav", { clear = true })
  vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
    group = group,
    callback = function()
      set_user_var("IS_NVIM", "true")
    end,
  })
  -- 종료·일시 중지하면 지워서, 셸로 돌아온 패널에서 C-h 등이 패널 이동으로 동작하게 한다
  vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
    group = group,
    callback = function()
      set_user_var("IS_NVIM", "")
    end,
  })
end

return M
