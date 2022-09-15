-- keymap can use string | function
-----------------------------------
local wk = require('which-key')

wk.register({
  b = {
    name = 'buffer & breakpoint',
    a = { '<cmd>bufdo bd<CR>', 'buffer delete all' },
    b = { function () require("dap").toggle_breakpoint() end, 'breakpoint' },
    d = { '<cmd>bdelete<CR>', 'buffer delete' },
    h = { '<cmd>sb<CR>', 'split horizontal' },
    v = { '<cmd>vs<CR>', 'spit vertical' },
  },
  d = {
    name = 'debug',
    f = { function () require('dap-python').test_class() end, 'test class(python)' },
    g = { function () require('dap-go').debug_test() end, 'test debug(go)' },
    l = { function () require'dap'.run_last() end, 'last run' },
    n = { function () require('dap-python').test_method() end, 'test method(python)' },
    r = { function () require'dap'.repl.open() end, 'open repl' },
    t = { function () require("dapui").toggle() end, 'open dap-ui' },
  },
  f = {
    name = 'find',
    b = { function () require('telescope.builtin').buffers() end, 'find buffers' },
    c = { function () require('telescope.builtin').git_bcommits() end, 'find git commits' },
    f = { function () require('telescope.builtin').find_files() end, 'find files(telescope)' },
    g = { function () require('telescope.builtin').live_grep() end, 'grep files' },
    h = { function () require('telescope.builtin').help_tags() end, 'find helptag' },
    k = { function () require('telescope.builtin').keymaps() end, 'find keymap' },
    n = { '<cmd>NvimTreeFindFile<CR>', 'find files(nvim-tree)' },
    t = { function () require('telescope.builtin').git_commits() end, 'find total commits' },
  },
  l = {
    name = 'lazy',
    d = { function () LazyDocker:toggle() end, 'lazy docker' },
    g = { function () LazyGit:toggle() end, 'lazy git' },
    n = { function () LazyNpm:toggle() end, 'lazy npm' },
  },
  n = { '<cmd>NvimTreeToggle<CR>', 'nvim tree' },
  t = {
    name = 'tab & toggle',
    d = { '<cmd>tabclose<CR>', 'tab close' },
    m = { '<cmd>MinimapToggle<CR>', 'minimap' },
    n = { '<cmd>tabnew<CR>', 'new tab' },
    t = { '<cmd>TagbarToggle<CR>', 'tagbar'},
  },
}, {
  prefix = '<leader>'
})

wk.register({
  b = { '<cmd>bp<cr>', 'buffer previous' },
  d = { vim.diagnostic.goto_prev, 'diagnostic previous' },
  t = { '<cmd>tabprev<CR>', 'tab previous' },
}, {
  prefix = '['
})

wk.register({
  b = { '<cmd>bn<cr>', 'buffer next' },
  d = { vim.diagnostic.goto_next, 'diagnostic next' },
  t = { '<cmd>tabnext<CR>', 'tab next' },
}, {
  prefix = ']'
})

-- for nvim-tree
vim.keymap.set('n', '<Leader>rn', '<cmd>NvimTreeRefresh<CR>')
-- for nvim-dap
vim.keymap.set('n', '<F5>', function () require'dap'.continue() end, { silent = true })
vim.keymap.set('n', '<F10>', function () require'dap'.step_over() end, { silent = true })
vim.keymap.set('n', '<F11>', function () require'dap'.step_into() end, { silent = true })
vim.keymap.set('n', '<F12>', function () require'dap'.step_out() end, { silent = true })
vim.keymap.set('n', '<Leader>B', function () require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { silent = true })
vim.keymap.set('n', '<Leader>lp', function () require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { silent = true }) 
-- for nvim-dap-python
vim.keymap.set('v', '<leader>ds <ESC>', function () require('dap-python').debug_selection() end, { silent = true })
-- for nvim-dap-ui
vim.keymap.set('v', '<Leader>ev', function () require("dapui").eval() end)
-- for bufferlie
vim.keymap.set('n', '<leader>1', function () require("bufferline").go_to_buffer(1, true) end, { silent = true })
vim.keymap.set('n', '<leader>2', function () require("bufferline").go_to_buffer(2, true) end, { silent = true })
vim.keymap.set('n', '<leader>3', function () require("bufferline").go_to_buffer(3, true) end, { silent = true })
vim.keymap.set('n', '<leader>4', function () require("bufferline").go_to_buffer(4, true) end, { silent = true })
vim.keymap.set('n', '<leader>5', function () require("bufferline").go_to_buffer(5, true) end, { silent = true })
vim.keymap.set('n', '<leader>6', function () require("bufferline").go_to_buffer(6, true) end, { silent = true })
vim.keymap.set('n', '<leader>7', function () require("bufferline").go_to_buffer(7, true) end, { silent = true })
vim.keymap.set('n', '<leader>8', function () require("bufferline").go_to_buffer(8, true) end, { silent = true })
vim.keymap.set('n', '<leader>9', function () require("bufferline").go_to_buffer(9, true) end, { silent = true }) 
-- for wrap
vim.keymap.set('n', 'j', 'v:count ? "j" : "gj"', { expr = true })
vim.keymap.set('n', 'k', 'v:count ? "k" : "gk"', { expr = true })
