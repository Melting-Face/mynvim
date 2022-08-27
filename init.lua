require('plugins')

vim.notify = require'notify'
async = require'plenary.async'
dap = require'dap'

OS = 'mac'
HOME = io.popen('echo $HOME'):read('l')
MASON = HOME .. '/.local/share/nvim/mason'
PACKER = HOME .. '/.local/share/nvim/site/pack/packer/start'

require('others.options')
require('others.nvim-treesitter')
require('others.gitsigns')
require('others.nvim-dap')
require('others.nvim-cmp')
require('others.nvim-notify')
require('others.minimap')
require('others.keymap')

vim.cmd[[colorscheme tokyonight]]
