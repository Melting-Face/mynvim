local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- OneDark 색상 스킴
config.color_scheme = "OneDark (base16)"

-- Windows에서는 PowerShell 7을 기본 셸로 사용
if wezterm.target_triple:find("windows") then
  config.default_prog = { "pwsh.exe", "-NoLogo" }
  -- WSL을 기본으로 쓰려면 위 default_prog 대신 아래 줄의 주석을 풀고 배포판 이름을 맞춘다
  -- config.default_domain = "WSL:Ubuntu"
end

-- 로컬 mux 서버(unix domain)에서 셸을 돌려, 창을 닫거나 prefix + d로 떼어도 작업이 살아 있게 한다
-- 서버가 없으면 WezTerm이 띄운다. 서버도 같은 wezterm.lua를 읽는다
config.unix_domains = { { name = "unix" } }
-- WezTerm을 켜면 항상 mux 서버에 붙는다. 문제가 생기면 이 줄만 주석 처리하면 예전 로컬 모드로 돌아간다
config.default_gui_startup_args = { "connect", "unix" }

-- tmux와 같은 키로 WezTerm 패널·탭을 쓴다 (모든 OS 공통)
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.scrollback_lines = 50000
-- 탭 바 번호를 tmux 창 번호처럼 0부터 표시한다 (기본은 1부터라 prefix + 숫자와 한 칸 어긋난다)
config.tab_and_split_indices_are_zero_based = true

-- prefix + H/J/K/L 뒤 0.5초 안에 다시 누르면 prefix 없이 반복 (tmux bind -r, repeat-time 500ms)
local resize_mode = act.ActivateKeyTable({
  name = "resize_pane",
  one_shot = false,
  until_unknown = true,
  timeout_milliseconds = 500,
  replace_current = true,
})

config.keys = {
  -- prefix + C-a: 셸이나 nvim에 C-a 전달
  { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
  -- 패널 분할: " 위아래, % 좌우
  { key = '"', mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "%", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  -- 패널 이동, 확대, 닫기
  { key = "LeftArrow", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "DownArrow", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "UpArrow", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "RightArrow", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
  -- 패널 크기 조절 (반복 가능)
  { key = "H", mods = "LEADER", action = act.Multiple({ act.AdjustPaneSize({ "Left", 2 }), resize_mode }) },
  { key = "J", mods = "LEADER", action = act.Multiple({ act.AdjustPaneSize({ "Down", 2 }), resize_mode }) },
  { key = "K", mods = "LEADER", action = act.Multiple({ act.AdjustPaneSize({ "Up", 2 }), resize_mode }) },
  { key = "L", mods = "LEADER", action = act.Multiple({ act.AdjustPaneSize({ "Right", 2 }), resize_mode }) },
  -- 탭(tmux window): 새로 만들기, 이동, 목록, 이름 바꾸기, 닫기
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = "w", mods = "LEADER", action = act.ShowTabNavigator },
  {
    key = ",",
    mods = "LEADER",
    action = act.PromptInputLine({
      description = "탭 이름",
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
  { key = "&", mods = "LEADER", action = act.CloseCurrentTab({ confirm = true }) },
  -- 복사 모드 (vi 키)
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
  -- mux 서버에서 떼어 낸다 (셸과 작업은 계속 실행, WezTerm을 다시 열면 이어짐)
  { key = "d", mods = "LEADER", action = act.DetachDomain("CurrentPaneDomain") },
  -- C-l은 패널 이동에 쓰므로, 셸 화면 지우기는 prefix + C-l로 보낸다
  { key = "l", mods = "LEADER|CTRL", action = act.SendKey({ key = "l", mods = "CTRL" }) },
}

-- C-h/j/k/l 패널 이동, A-h/j/k/l 크기 조절. nvim 패널이면 키를 nvim에 넘긴다
-- nvim(configs.wezterm_nav)이 user var IS_NVIM을 알리고, nvim 창 끝에서는 wezterm cli로 패널을 움직인다
local directions = { h = "Left", j = "Down", k = "Up", l = "Right" }
for key, direction in pairs(directions) do
  for mods, pane_action in pairs({
    CTRL = act.ActivatePaneDirection(direction),
    META = act.AdjustPaneSize({ direction, 2 }),
  }) do
    table.insert(config.keys, {
      key = key,
      mods = mods,
      action = wezterm.action_callback(function(window, pane)
        if pane:get_user_vars().IS_NVIM == "true" then
          window:perform_action(act.SendKey({ key = key, mods = mods }), pane)
        else
          window:perform_action(pane_action, pane)
        end
      end),
    })
  end
end
-- prefix + 0~9: 해당 번호 탭으로 이동 (tmux처럼 0부터)
for i = 0, 9 do
  table.insert(config.keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i) })
end
-- 기본 키 설정처럼 Shift가 필요한 문자는 SHIFT를 붙인 조합도 등록해 키보드 배열과 상관없이 동작하게 한다
for _, binding in ipairs({ table.unpack(config.keys) }) do
  if binding.mods == "LEADER" and binding.key:match('^[%u"%%&]$') then
    table.insert(config.keys, { key = binding.key, mods = "LEADER|SHIFT", action = binding.action })
  end
end

config.key_tables = {
  resize_pane = {
    { key = "H", action = act.Multiple({ act.AdjustPaneSize({ "Left", 2 }), resize_mode }) },
    { key = "J", action = act.Multiple({ act.AdjustPaneSize({ "Down", 2 }), resize_mode }) },
    { key = "K", action = act.Multiple({ act.AdjustPaneSize({ "Up", 2 }), resize_mode }) },
    { key = "L", action = act.Multiple({ act.AdjustPaneSize({ "Right", 2 }), resize_mode }) },
    { key = "Escape", action = act.PopKeyTable },
  },
}
for _, binding in ipairs({ table.unpack(config.key_tables.resize_pane) }) do
  if binding.key:match("^%u$") then
    table.insert(config.key_tables.resize_pane, { key = binding.key, mods = "SHIFT", action = binding.action })
  end
end

-- prefix가 눌려 있으면 오른쪽 상태줄에 표시 (tmux-prefix-highlight 대용)
wezterm.on("update-status", function(window, _)
  local text = ""
  if window:leader_is_active() then
    text = " PREFIX "
  elseif window:active_key_table() then
    text = " " .. window:active_key_table():upper() .. " "
  end
  window:set_right_status(text)
end)

return config
