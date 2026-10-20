vim.opt.rtp:prepend(vim.fn.getcwd())
-- 설치되지 않은 플러그인 참조나 실행되지 않는 코드가 다시 들어오지 않았는지 검사
local patterns = {
  '"lsp_progress"',
  '"tabnine"',
  '"cmp_git"',
  "code_actions.refactoring",
  "none-ls-extras",
  "ipairs(lang_doc_map)",
}
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
