vim.opt.rtp:prepend(vim.fn.getcwd())
-- nvim-dap-python 설정: 어댑터는 mason의 debugpy 전용 venv로 실행하고,
-- 디버그 대상 프로그램은 프로젝트 venv(.venv, venv), 없으면 시스템 python으로 실행한다
local paths = require("configs.paths")
local root = vim.fn.tempname()
paths.mason_package = function(name)
  return root .. "/mason/" .. name
end
paths.python = function()
  return "/usr/bin/python3"
end

local function touch(path)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile({}, path)
end

local setup_arg
local dap_python = {
  setup = function(python)
    setup_arg = python
  end,
}
package.loaded["dap-python"] = dap_python
local notes = {}
vim.notify_once = function(msg, level)
  table.insert(notes, { msg = msg, level = level })
  return true
end

local spec
for _, entry in ipairs(dofile("lua/plugins/dap.lua")) do
  if type(entry) == "table" and entry[1] == "mfussenegger/nvim-dap-python" then
    spec = entry
  end
end
assert(spec, "nvim-dap-python 스펙이 없음")

-- debugpy가 아직 설치되지 않았으면 설정하지 않고 WARN 안내만 한 번 한다
paths.is_windows = function()
  return false
end
spec.config()
assert(setup_arg == nil, "debugpy가 없는데 setup이 호출됨")
assert(#notes == 1 and notes[1].level == vim.log.levels.WARN, "debugpy 미설치 안내가 없음")

-- 설치가 중간에 끊겨 venv python만 있고 mason 영수증이 없으면 설치되지 않은 것으로 본다
touch(root .. "/mason/debugpy/venv/bin/python")
spec.config()
assert(setup_arg == nil, "영수증 없는 반쪽 설치인데 setup이 호출됨")

-- 설치가 끝났으면(영수증 있음) OS별 venv python으로 setup한다
touch(root .. "/mason/debugpy/mason-receipt.json")
for _, case in ipairs({
  { windows = false, exe = "/venv/bin/python" },
  { windows = true, exe = "/venv/Scripts/python.exe" },
}) do
  paths.is_windows = function()
    return case.windows
  end
  local adapter_python = root .. "/mason/debugpy" .. case.exe
  touch(adapter_python)
  setup_arg = nil
  spec.config()
  assert(setup_arg == adapter_python, "windows=" .. tostring(case.windows) .. " setup=" .. tostring(setup_arg))
end

-- 디버그 대상 python: 프로젝트 .venv가 있으면 그것, 없으면 시스템 python
paths.is_windows = function()
  return false
end
local project = vim.fn.tempname()
vim.fn.mkdir(project, "p")
vim.fn.chdir(project)
assert(
  dap_python.resolve_python() == "/usr/bin/python3",
  "venv가 없을 때: " .. tostring(dap_python.resolve_python())
)
touch(project .. "/.venv/bin/python")
assert(
  dap_python.resolve_python() == project .. "/.venv/bin/python",
  "venv가 있을 때: " .. tostring(dap_python.resolve_python())
)
os.exit(0)
