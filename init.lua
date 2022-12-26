vim.g.mapleader = ','

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

require'lazy'.setup('plugins', {
  concurrency = 50,
})

require'impatient'
require'others.options'
require'others.variables'
require'others.nvim-dap'
require'others.nvim-cmp'
require'others.nvim-notify'
require'others.toggle-term'
require'others.keymap'

