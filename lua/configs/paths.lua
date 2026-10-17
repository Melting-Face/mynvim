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

return M
