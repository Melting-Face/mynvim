local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- tmux 테마와 맞춘 색상 스킴
config.color_scheme = "OneDark (base16)"

-- Windows에서는 PowerShell 7을 기본 셸로 사용
if wezterm.target_triple:find("windows") then
  config.default_prog = { "pwsh.exe", "-NoLogo" }
  -- WSL을 기본으로 쓰려면 위 default_prog 대신 아래 줄의 주석을 풀고 배포판 이름을 맞춘다
  -- config.default_domain = "WSL:Ubuntu"
end

return config
