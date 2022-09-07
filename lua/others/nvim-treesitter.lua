ASYNC.run(function ()
  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      'bash',
      'javascript',
      'json',
      'lua',
      'python',
      'vim',
      'sql',
      'tsx',
      'typescript',
      'yaml',
    },
  }
end)

