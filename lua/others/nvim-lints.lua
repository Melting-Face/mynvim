require('lint').linters_by_ft = {
  javascript = { 'eslint' },
  lua = { 'luacheck' },
  markdown = { 'markdownlint' },
  python = { 'flake8' },
  typescript = { 'eslint' },
  yaml = { 'yamllint' },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
