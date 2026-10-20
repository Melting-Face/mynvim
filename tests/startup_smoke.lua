-- 전체 설정 시작 스모크 검사: 전체 설정으로 픽스처 파일을 연 뒤 실행한다
-- 사용: nvim --headless tests/fixtures/smoke.c "+luafile tests/startup_smoke.lua"
-- 성공 시 "PASS startup" 출력 후 종료 코드 0, 실패 시 이유를 출력하고 종료 코드 1
local function fail(msg)
  io.stderr:write("FAIL startup: " .. msg .. "\n")
  vim.cmd("cquit 1")
end

-- VimEnter 이후의 lazy 이벤트와 지연 실행이 처리되기를 기다린다
vim.wait(2000)

local buf = vim.api.nvim_get_current_buf()
local ok, err = pcall(function()
  -- 검사 목록
  assert(vim.v.errmsg == "", "errmsg: " .. vim.v.errmsg)
  local messages = vim.api.nvim_exec2("messages", { output = true }).output
  assert(not messages:find("E%d+:") and not messages:find("Error"), "messages: " .. messages)
  assert(vim.api.nvim_buf_get_name(buf):find("smoke.c", 1, true), "픽스처 파일이 열려 있지 않음")
end)
if not ok then
  fail(tostring(err))
end
io.stdout:write("PASS startup\n")
vim.cmd("qa!")
