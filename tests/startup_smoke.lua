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
  assert(
    vim.v.vim_did_enter == 1,
    "VimEnter 전에 검사가 실행됨 (VimEnter에서 로드되는 플러그인이 검사되지 않음)"
  )
  assert(vim.v.errmsg == "", "errmsg: " .. vim.v.errmsg)
  local messages = vim.api.nvim_exec2("messages", { output = true }).output
  -- 대소문자와 관계없이 error, 그리고 mason 설치 실패 같은 failed 메시지도 오류로 본다
  local lowered = messages:lower()
  assert(
    not messages:find("E%d+:") and not lowered:find("error") and not lowered:find("failed"),
    "messages: " .. messages
  )
  assert(vim.api.nvim_buf_get_name(buf):find("smoke.c", 1, true), "픽스처 파일이 열려 있지 않음")
  -- headless 기본 폭(80칸)에서는 %< 로 잘리므로 넉넉한 폭으로 평가한다
  local statusline = vim.api.nvim_eval_statusline(vim.o.statusline, { maxwidth = 200 }).str
  assert(statusline:find("smoke.c", 1, true), "상태줄에 파일명이 없음: " .. statusline)
  -- treesitter: 모든 파일에서 하이라이트, 텍스트 오브젝트 키가 기본 키와 겹치지 않음
  assert(vim.treesitter.highlighter.active[buf], "treesitter 하이라이트가 꺼져 있음")
  assert(vim.fn.maparg(",sn", "n") ~= "", ",sn(파라미터 swap) 키가 없음")
  assert(vim.fn.maparg(",a", "n", false, true).buffer ~= 1, ",a가 버퍼 로컬 swap으로 덮여 있음")
  assert((vim.fn.maparg("]d", "n", false, true).desc or ""):lower():find("diagnostic"), "]d가 진단 이동이 아님")
  assert(vim.fn.maparg("]i", "n") ~= "", "]i(조건문 이동) 키가 없음")
  -- 언어별 테스트 키: c 버퍼에는 없고 python 버퍼에서는 dap-python 키
  assert(vim.fn.maparg(",dc", "n") == "", "c 버퍼에 ,dc가 있음")
  vim.cmd.edit("tests/fixtures/smoke.py")
  vim.wait(500)
  assert(
    vim.fn.maparg(",dc", "n", false, true).desc == "python test class",
    "python 버퍼의 ,dc가 dap-python이 아님"
  )
end)
if not ok then
  fail(tostring(err))
end
io.stdout:write("PASS startup\n")
vim.cmd("qa!")
