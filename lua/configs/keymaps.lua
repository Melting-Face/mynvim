-- keymap can use string | function
-----------------------------------
local tt  = require("toggleterm.terminal").Terminal
local wk  = require('which-key')
local gs  = require('gitsigns')

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
  ['1'] = { function () require("bufferline").go_to_buffer(1, true) end, 'go to buffer index 1'},
  ['2'] = { function () require("bufferline").go_to_buffer(2, true) end, 'go to buffer index 2'},
  ['3'] = { function () require("bufferline").go_to_buffer(3, true) end, 'go to buffer index 3'},
  ['4'] = { function () require("bufferline").go_to_buffer(4, true) end, 'go to buffer index 4'},
  ['5'] = { function () require("bufferline").go_to_buffer(5, true) end, 'go to buffer index 5'},
  ['6'] = { function () require("bufferline").go_to_buffer(6, true) end, 'go to buffer index 6'},
  ['7'] = { function () require("bufferline").go_to_buffer(7, true) end, 'go to buffer index 7'},
  ['8'] = { function () require("bufferline").go_to_buffer(8, true) end, 'go to buffer index 8'},
  ['9'] = { function () require("bufferline").go_to_buffer(9, true) end, 'go to buffer index 9'},
  h = {
    h = { function () htop:toggle() end, 'htop'},
    b = { gs.toggle_current_line_blame, 'gitsigns blame' },
    d = { gs.toggle_deleted, 'gitsigns deleted' },
    f = { function () gs.blame_line{ full=true } end, 'git blame all'},
    l = { function () lazydocker:toggle() end, 'lazy docker' },
    t = { gs.diffthis, 'diff this'},
    p = { gs.preview_hunk, 'preview huck'},
  },
  r = {
    name = 'rust_tools & rest-nvim & refactoring',
    b = { function () require('refactoring').refactor('Extract Block') end, 'refactoring extract block' },
    f = {
      function () require('refactoring').refactor('Extract Block To File') end,
      'refactoring extract block to file',
    },
    i = { function () require('refactoring').refactor('Inline Variable') end, 'refactoring inline variable' },
  },
  t = {
    name = 'tab & toggle',
    c = { '<cmd>tabclose<CR>', 'tab close' },
  },
}, {
  prefix = '<leader>'
})

-- INFO: <leader> key (visual)
wk.register({
  r = {
    name = 'refactoring',
    e = { function () require('refactoring').refactor('Extract Function') end, 'extract function' },
    f = { function () require('refactoring').refactor('Extract Function To File') end, 'extract function to file' },
    i = { function () require('refactoring').refactor('Inline Variable') end, 'inline variable'},
    v = { function () require('refactoring').refactor('Extract Variable') end, 'extract variable' },
  },
}, {
  mode = "v",
  prefix = '<leader>',
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
