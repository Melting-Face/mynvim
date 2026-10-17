-- nvim-treesitter(master) 스모크 검사: 전체 설정으로 lua 파일을 연 뒤 실행한다
-- 사용: nvim --headless tests/lua/paths_spec.lua "+luafile tests/treesitter_smoke.lua"
-- 성공 시 "PASS treesitter" 출력 후 종료 코드 0, 실패 시 오류를 출력하고 종료 코드 1
local function fail(msg)
  io.stderr:write("FAIL treesitter: " .. msg .. "\n")
  vim.cmd("cquit 1")
end

local buf = vim.api.nvim_get_current_buf()
local ok, err = pcall(function()
  -- lazy=true 이므로 직접 로드한다 (이미 로드되었으면 아무것도 하지 않음)
  require("lazy").load({ plugins = { "nvim-treesitter" } })
  require("nvim-treesitter.configs")
  local parser = vim.treesitter.get_parser(buf, "lua")
  assert(parser, "lua 파서를 만들 수 없음")
  parser:parse()
  -- 하이라이터가 자동으로 붙지 않는 nvim 버전이면 직접 붙여 본다
  if not vim.treesitter.highlighter.active[buf] then
    vim.treesitter.start(buf, "lua")
  end
end)
if not ok then
  fail(tostring(err))
end
if not vim.treesitter.highlighter.active[buf] then
  fail("treesitter 하이라이터가 붙지 않음")
end
if vim.v.errmsg ~= "" then
  fail("errmsg: " .. vim.v.errmsg)
end
io.stdout:write("PASS treesitter\n")
vim.cmd("qa!")
