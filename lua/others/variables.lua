
require'plenary.async'

OS = 'mac'
DAP = require'dap'
HOME = io.popen('echo $HOME'):read('l')
MASON = HOME .. '/.local/share/nvim/mason'
PACKER = HOME .. '/.local/share/nvim/site/pack/packer/start'

vim.notify = require'notify'
vim.cmd[[colorscheme tokyonight]]
