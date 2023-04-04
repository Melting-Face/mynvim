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
  c = {
    name = 'current',
    n = { '<cmd>NvimTreeFindFile<CR>', 'find files(nvim-tree)' },
  },
  h = {
    h = { function () htop:toggle() end, 'htop'},
    b = { gs.toggle_current_line_blame, 'gitsigns blame' },
    d = { gs.toggle_deleted, 'gitsigns deleted' },
    f = { function () gs.blame_line{ full=true } end, 'git blame all'},
    t = { gs.diffthis, 'diff this'},
    p = { gs.preview_hunk, 'preview huck'},
  },
  l = {
    name = 'lazy',
    d = { function () lazydocker:toggle() end, 'lazy docker' },
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
    d = { '<cmd>DBUIToggle<CR>', 'db ui' },
    m = { '<cmd>MinimapToggle<CR>', 'minimap' },
    n = { '<cmd>NvimTreeToggle<CR>', 'nvim tree' },
    p = { '<cmd>MarkdownPreviewToggle<CR>', 'markdown preview' },
    x = { '<cmd>TroubleToggle<CR>', 'trouble' },
  },
  u = {
    name = 'db ui',
    a = { '<cmd>DBUIAddConnection<CR>', 'add connection' },
    f = { '<cmd>DBUIFindBuffer<CR>', 'find buffer' },
    l = { '<cmd>DBUILastQueryInfo<CR>', 'last query info' },
    r = { '<cmd>DBUIRenameBuffer<CR>', 'rename buffer' },
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
  c = {
    function()
      require("todo-comments").jump_prev()
    end,
    'Previous todo comment',
  },
  d = { vim.diagnostic.goto_prev, 'diagnostic previous' },
  t = { '<cmd>tabprev<CR>', 'tab previous' },
}, {
  prefix = '['
})

-- INFO: ']' key
wk.register({
  b = { '<cmd>bn<cr>', 'buffer next' },
  c = {
    function()
      require("todo-comments").jump_next()
    end,
    'Next todo comment',
  },
  d = { vim.diagnostic.goto_next, 'diagnostic next' },
  t = { '<cmd>tabnext<CR>', 'tab next' },
}, {
  prefix = ']'
})

-- INFO: For wrap
vim.keymap.set('n', 'j', '"gj"', { expr = true })
vim.keymap.set('n', 'k', '"gk"', { expr = true })
