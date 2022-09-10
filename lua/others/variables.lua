OS = 'mac'
DAP = require'dap'
HOME = os.getenv'HOME'
ASYNC = require'plenary.async'
MASON = HOME .. '/.local/share/nvim/mason'
PACKER = HOME .. '/.local/share/nvim/site/pack/packer/start'

vim.notify = require'notify'
vim.cmd[[colorscheme tokyonight]]
