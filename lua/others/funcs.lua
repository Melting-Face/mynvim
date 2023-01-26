function SETCOLUMNLINE()
  local filetype = vim.bo.filetype
  if filetype == 'javascript' then
    vim.cmd[[set cc=81]]
  elseif filetype == 'typescript' then
    vim.cmd[[set cc=81]]
  elseif filetype == 'python' then
    vim.cmd[[set cc=89]]
  elseif filetype == 'lua' then
    vim.cmd[[set cc=121]]
  else
    vim.cmd[[set cc=]]
  end
end
