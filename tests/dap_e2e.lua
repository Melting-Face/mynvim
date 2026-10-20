-- 디버거 E2E: 전체 설정으로 픽스처를 연 뒤, BREAK 마커 줄에 중단점을 걸고 디버그 세션을 시작해
-- 그 줄에서 실제로 멈추는지 확인한다
-- 사용: nvim --headless tests/fixtures/dap/hello.py "+luafile tests/dap_e2e.lua"
-- 성공 시 "PASS dap <filetype>" 후 종료 코드 0, 실패 시 이유를 출력하고 종료 코드 1
-- 대기 상한(ms)은 DAP_E2E_TIMEOUT 환경 변수로 바꿀 수 있다 (기본 60000)

-- +luafile은 VimEnter 전에 실행되므로, VimEnter가 끝난 뒤 이 파일을 다시 실행한다
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

local timeout = tonumber(vim.env.DAP_E2E_TIMEOUT or "60000")
local buf = vim.api.nvim_get_current_buf()
local ft = vim.bo[buf].filetype
local file = vim.api.nvim_buf_get_name(buf)

-- dap이 vim.notify로 알리는 오류를 실패 이유에 함께 남긴다
local notes = {}
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  if level and level >= vim.log.levels.WARN then
    table.insert(notes, tostring(msg))
  end
  return original_notify(msg, level, opts)
end

local function fail(msg)
  if #notes > 0 then
    msg = msg .. " | 알림: " .. table.concat(notes, " / ")
  end
  io.stderr:write("FAIL dap " .. ft .. ": " .. msg .. "\n")
  vim.cmd("cquit 1")
end

-- 언어별 launch 설정 (Task 2, 3에서 c, java를 추가한다)
local launch_configs = {
  python = function()
    return { type = "python", request = "launch", name = "dap e2e", program = file, console = "internalConsole" }
  end,
}

local ok, err = pcall(function()
  assert(launch_configs[ft], "launch 설정이 없는 filetype")
  local marker
  for i, text in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if text:find("BREAK", 1, true) then
      marker = i
      break
    end
  end
  assert(marker, "BREAK 마커 줄이 없음")

  local dap = require("dap")
  local config = launch_configs[ft]()
  -- 어댑터는 filetype 플러그인(dap-python 등)이 로드되며 등록된다
  vim.wait(5000, function()
    return dap.adapters[config.type] ~= nil
  end, 100)
  assert(dap.adapters[config.type], "어댑터가 등록되지 않음: " .. config.type)

  require("dap.breakpoints").set({}, buf, marker)
  local stopped_line
  dap.listeners.after.stackTrace["dap_e2e"] = function(session)
    if session.current_frame then
      stopped_line = session.current_frame.line
    end
  end
  dap.run(config)
  local done = vim.wait(timeout, function()
    return stopped_line ~= nil
  end, 100)
  assert(done, timeout .. "ms 안에 중단점에서 멈추지 않음")
  assert(stopped_line == marker, "멈춘 줄 " .. tostring(stopped_line) .. ", 기대 " .. marker)

  dap.terminate()
  vim.wait(10000, function()
    return dap.session() == nil
  end, 100)
end)
if not ok then
  fail(tostring(err))
  return
end
io.stdout:write("PASS dap " .. ft .. "\n")
vim.cmd("qa!")
