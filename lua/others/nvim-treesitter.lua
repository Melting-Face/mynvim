ASYNC.run(function ()
  require'nvim-treesitter.configs'.setup {
    sync_install = true,
    ensure_installed = {
      'bash',
      'c',
      'dockerfile',
      'go',
      'javascript',
      'json',
      'lua',
      'make',
      'markdown',
      'python',
      'regex',
      'sql',
      'tsx',
      'typescript',
      'vim',
      'yaml',
    },
  }
end)

