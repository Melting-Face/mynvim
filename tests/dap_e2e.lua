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

-- 언어별 launch 설정
local launch_configs = {
  python = function()
    return { type = "python", request = "launch", name = "dap e2e", program = file, console = "internalConsole" }
  end,
  -- 픽스처를 디버그 정보와 함께 컴파일한 뒤 codelldb로 실행한다 (cc, gcc, clang, zig cc 중 처음 찾은 것)
  c = function()
    local out = vim.fn.tempname() .. (vim.fn.has("win32") == 1 and ".exe" or "")
    local cmd
    for _, cc in ipairs({ "cc", "gcc", "clang" }) do
      if vim.fn.executable(cc) == 1 then
        cmd = { cc }
        break
      end
    end
    cmd = cmd or (vim.fn.executable("zig") == 1 and { "zig", "cc" })
    assert(cmd, "C 컴파일러(cc, gcc, clang, zig)를 찾을 수 없음")
    vim.list_extend(cmd, { "-g", "-O0", "-o", out, file })
    -- zig는 처음 쓸 때 libc를 빌드해 캐시하므로 1~2분 걸릴 수 있다 (상한 5분)
    local result = vim.system(cmd):wait(300000)
    assert(result.code == 0, "컴파일 실패: " .. (result.stderr or ""))
    -- headless에서는 통합 터미널(터미널 버퍼)을 열지 않도록 출력은 디버그 콘솔로 보낸다
    return {
      type = "codelldb",
      request = "launch",
      name = "dap e2e",
      program = out,
      cwd = vim.fs.dirname(file),
      terminal = "console",
    }
  end,
  -- jdtls가 프로젝트를 불러와 Hello를 main 클래스로 찾을 때까지 기다린 뒤 실행한다
  -- (projectName, classpath, java 실행 파일은 nvim-jdtls가 채운다)
  -- 요청은 jdtls에만 보낸다 (null-ls처럼 붙어 있는 다른 클라이언트가 바로 응답하면 jdtls를 기다리지 않게 됨)
  -- request_sync는 안에서 vim.wait를 쓰므로 vim.wait 조건 함수 안에서 부르지 않는다
  -- (안쪽 vim.wait가 바로 끝나면 바깥 vim.wait가 시간 제한과 간격을 무시하고 계속 돎, Neovim 0.12.2에서 확인)
  java = function()
    local deadline = vim.uv.hrtime() + timeout * 1e6
    local found = false
    while not found and vim.uv.hrtime() < deadline do
      local client = vim.lsp.get_clients({ bufnr = buf, name = "jdtls" })[1]
      if client then
        local response =
          client:request_sync("workspace/executeCommand", { command = "vscode.java.resolveMainClass" }, 5000, buf)
        for _, main in ipairs(response and response.result or {}) do
          found = found or main.mainClass == "Hello"
        end
      end
      if not found then
        vim.wait(2000)
      end
    end
    assert(found, timeout .. "ms 안에 jdtls가 Hello main 클래스를 찾지 못함")
    return { type = "java", request = "launch", name = "dap e2e", mainClass = "Hello" }
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
