vim.opt.rtp:prepend(vim.fn.getcwd())
-- paths.python(): Windows는 python을, 그 밖에는 python3를 먼저 찾는다
local paths = require("configs.paths")
local real_is_windows = paths.is_windows
local found = { python = "/bin/python", python3 = "/bin/python3" }
vim.fn.exepath = function(name)
  return found[name] or ""
end

paths.is_windows = function()
  return true
end
assert(paths.python() == "/bin/python", "Windows는 python을 먼저 써야 함")

paths.is_windows = function()
  return false
end
assert(paths.python() == "/bin/python3", "Windows가 아니면 python3를 먼저 써야 함")

-- 우선 이름이 없으면 다음 이름으로 넘어간다
found.python3 = nil
assert(paths.python() == "/bin/python")
found.python = nil
assert(paths.python() == "")

paths.is_windows = real_is_windows
os.exit(0)
