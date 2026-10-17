vim.opt.rtp:prepend(vim.fn.getcwd())
-- OS 종속 패턴이 남아있는지 검사
local patterns = { 'os.getenv("HOME")', "which python3", "| grep" }
local files = {}
for _, dir in ipairs({ "lua", "ftplugin" }) do
  vim.list_extend(files, vim.fn.globpath(dir, "**/*.lua", false, true))
end
assert(#files > 0, "검사할 파일이 없음")
for _, file in ipairs(files) do
  local content = table.concat(vim.fn.readfile(file), "\n")
  for _, p in ipairs(patterns) do
    assert(not content:find(p, 1, true), file .. " 에 금지 패턴 존재: " .. p)
  end
end
os.exit(0)
