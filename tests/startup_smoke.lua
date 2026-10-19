-- 전체 설정 시작 스모크 검사: 전체 설정으로 픽스처 파일을 연 뒤 실행한다
-- 사용: nvim --headless tests/fixtures/smoke.c "+luafile tests/startup_smoke.lua"
-- 성공 시 "PASS startup" 출력 후 종료 코드 0, 실패 시 이유를 출력하고 종료 코드 1
-- +luafile은 VimEnter 전에 실행되므로, VimEnter가 끝난 뒤 이 파일을 다시 실행한다
-- (VimEnter에서 로드되는 telescope, bufferline 등도 검사 대상에 들어가게 하기 위함)
if vim.v.vim_did_enter == 0 then
  local script = debug.getinfo(1, "S").source:sub(2)
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(function()
        vim.cmd.luafile(script)
      end)
    end,
  })
  return
end

local function fail(msg)
  io.stderr:write("FAIL startup: " .. msg .. "\n")
  vim.cmd("cquit 1")
end

-- VimEnter 이후의 lazy 이벤트와 지연 실행이 처리되기를 기다린다
vim.wait(2000)

local buf = vim.api.nvim_get_current_buf()
local ok, err = pcall(function()
  -- 검사 목록
  assert(vim.v.vim_did_enter == 1, "VimEnter 전에 검사가 실행됨 (VimEnter에서 로드되는 플러그인이 검사되지 않음)")
  assert(vim.v.errmsg == "", "errmsg: " .. vim.v.errmsg)
  local messages = vim.api.nvim_exec2("messages", { output = true }).output
  assert(not messages:find("E%d+:") and not messages:find("Error"), "messages: " .. messages)
  assert(vim.api.nvim_buf_get_name(buf):find("smoke.c", 1, true), "픽스처 파일이 열려 있지 않음")
  -- headless 기본 폭(80칸)에서는 %< 로 잘리므로 넉넉한 폭으로 평가한다
  local statusline = vim.api.nvim_eval_statusline(vim.o.statusline, { maxwidth = 200 }).str
  assert(statusline:find("smoke.c", 1, true), "상태줄에 파일명이 없음: " .. statusline)
end)
if not ok then
  fail(tostring(err))
end
io.stdout:write("PASS startup\n")
vim.cmd("qa!")
