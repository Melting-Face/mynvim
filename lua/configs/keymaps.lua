-- keymap can use string | function
-----------------------------------
local tt  = require("toggleterm.terminal").Terminal
local wk  = require('which-key')

local lazydocker = tt:new({
	cmd = "lazydocker",
	direction = "float",
	float_opts = {
		border = "single",
	},
})

local htop = tt:new({
  cmd = "htop",
  direction = "float",
	float_opts = {
		border = "single",
	},
})

-- INFO: <leader> key (normal)
wk.register({
  h = {
    h = { function () htop:toggle() end, 'htop'},
    l = { function () lazydocker:toggle() end, 'lazy docker' },
    p = { "<cmd>cexpr system('refurb --quiet ' . shellescape(expand('%'))) | copen<cr>", 'refurb' },
  },
  t = {
    name = 'tab & toggle',
    c = { '<cmd>tabclose<CR>', 'tab close' },
  },
}, {
  prefix = '<leader>'
})

-- INFO: <space> key
wk.register({
  b = {
    name = 'buffer',
    a = { '<cmd>bufdo bd<CR>', 'buffer delete all' },
    x = { '<cmd>bdelete<CR>', 'buffer close' },
  },
  t = {
    name = 'tab',
    n = { '<cmd>tabnew<CR>', 'new tab' },
    x = { '<cmd>tabclose<CR>', 'tab close' },
  },
}, {
  prefix = '<space>'
})

-- INFO: '[' key
wk.register({
  b = { '<cmd>bp<cr>', 'buffer previous' },
  t = { '<cmd>tabprev<CR>', 'tab previous' },
}, {
  prefix = '['
})

-- INFO: ']' key
wk.register({
  b = { '<cmd>bn<cr>', 'buffer next' },
  t = { '<cmd>tabnext<CR>', 'tab next' },
}, {
  prefix = ']'
})

-- INFO: For wrap
vim.keymap.set('n', 'j', '"gj"', { expr = true })
vim.keymap.set('n', 'k', '"gk"', { expr = true })
