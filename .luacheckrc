std = "luajit"
globals = {
  "vim",
}
-- URL 등 긴 문자열이 있으므로 줄 길이는 stylua(column_width)에 맡긴다
max_line_length = false
-- wezterm.lua는 WezTerm 내장 Lua 5.4에서 실행되므로 table.unpack 등 5.4 표준을 허용한다
files["wezterm.lua"] = { std = "max" }
