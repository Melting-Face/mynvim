require('plugins')

vim.notify = require'notify'
vim.cmd[[colorscheme tokyonight]]
async = require'plenary.async'
dap = require'dap'

require('others.options')
require('others.nvim-treesitter')
require('others.gitsigns')
require('others.nvim-dap')
require('others.nvim-cmp')
require('others.nvim-notify')
require('others.minimap')
require('others.keymap')
