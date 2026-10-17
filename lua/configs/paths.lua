local M = {}

-- Windows 여부
function M.is_windows()
  return vim.fn.has("win32") == 1
end

-- mason 패키지 설치 경로
function M.mason_package(name)
  return vim.fn.stdpath("data") .. "/mason/packages/" .. name
end

-- Windows에서는 실행 파일에 .exe 확장자를 붙인다
function M.exe(path)
  if M.is_windows() then
    return path .. ".exe"
  end
  return path
end

-- 파이썬 실행 파일의 전체 경로 (없으면 빈 문자열)
-- Windows의 python3는 Microsoft Store 별칭(스텁)일 수 있으므로 python을 먼저 찾는다
function M.python()
  local names = M.is_windows() and { "python", "python3" } or { "python3", "python" }
  for _, name in ipairs(names) do
    local found = vim.fn.exepath(name)
    if found ~= "" then
      return found
    end
  end
  return ""
end

return M
