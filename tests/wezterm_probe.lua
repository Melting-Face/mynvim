-- wezterm.lua를 읽은 뒤 등록된 unix 도메인을 로그(DOMAIN <이름>)로 남기는 시험용 설정 파일
-- 저장소 루트에서 `wezterm --config-file tests/wezterm_probe.lua show-keys`로 쓴다
local wezterm = require("wezterm")
local config = dofile("wezterm.lua")
for _, domain in ipairs(config.unix_domains) do
  wezterm.log_error("DOMAIN " .. domain.name)
end
return config
