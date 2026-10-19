local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- tmux 테마와 맞춘 색상 스킴
config.color_scheme = "OneDark (base16)"

-- Windows에서는 PowerShell 7을 기본 셸로 사용
if wezterm.target_triple:find("windows") then
  config.default_prog = { "pwsh.exe", "-NoLogo" }
  -- WSL을 기본으로 쓰려면 위 default_prog 대신 아래 줄의 주석을 풀고 배포판 이름을 맞춘다
  -- config.default_domain = "WSL:Ubuntu"

  -- tmux를 쓸 수 없는 Windows 네이티브에서 tmux.conf와 같은 키로 WezTerm 멀티플렉서를 쓴다
  -- macOS/Linux/WSL은 진짜 tmux가 C-a를 받아야 하므로 적용하지 않는다
  config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
  config.scrollback_lines = 50000

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
  }
  -- prefix + 0~9: 해당 번호 탭으로 이동 (tmux처럼 0부터)
  for i = 0, 9 do
    table.insert(config.keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i) })
  end
  -- 기본 키 설정처럼 Shift가 필요한 문자는 SHIFT를 붙인 조합도 등록해 키보드 배열과 상관없이 동작하게 한다
  for _, binding in ipairs({ table.unpack(config.keys) }) do
    if binding.mods == "LEADER" and binding.key:match("^[%u\"%%&]$") then
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
end

return config
