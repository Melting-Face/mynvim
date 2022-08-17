require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    'bash',
    'css',
    'graphql',
    'html',
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
  sync_install = true,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
