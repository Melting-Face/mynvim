OS = 'mac'
HAS_DAP, DAP = pcall(require, 'dap')
HOME = os.getenv'HOME'
ASYNC = require'plenary.async'
MASON = HOME .. '/.local/share/nvim/mason/packages'
HIDDEN_FILE = false
