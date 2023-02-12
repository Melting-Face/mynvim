vim.api.nvim_create_autocmd(
  'FileType',
  {
    pattern = { 'lua', 'javascript', 'typescript', 'python' },
    command = [[lua SETCOLUMNLINE()]]
  }
)
