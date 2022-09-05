-- keymap can use string | function
-----------------------------------
-- for tagbar
vim.keymap.set('n', '<Leader>t', '<cmd>TagbarToggle<CR>')
-- for minimap
vim.keymap.set('n', '<Leader>m', '<cmd>MinimapToggle<CR>')
-- for nvim-tree
vim.keymap.set('n', '<Leader>n', '<cmd>NvimTreeToggle<CR>')
vim.keymap.set('n', '<Leader>rn', '<cmd>NvimTreeRefresh<CR>')
vim.keymap.set('n', '<Leader>fn', '<cmd>NvimTreeFindFile<CR>')
-- for buffer
vim.keymap.set('n', 'b]', '<cmd>bn<cr>', { silent = true })
vim.keymap.set('n', 'b[', '<cmd>bp<cr>', { silent = true })
vim.keymap.set('n', '<Leader>bdd', '<cmd>bdelete<CR>')
vim.keymap.set('n', '<Leader>bh', '<cmd>sb<CR>')
vim.keymap.set('n', '<Leader>bv', '<cmd>vs<CR>')
vim.keymap.set('n', '<Leader>bda', '<cmd>bufdo bd<CR>')
-- for tab
vim.keymap.set('n', '<Leader>tn', '<cmd>tabnew<CR>')
vim.keymap.set('n', '<Leader>td', '<cmd>tabclose<CR>')
vim.keymap.set('n', 't[', '<cmd>tabnext<CR>', { silent = true })
vim.keymap.set('n', 't]', '<cmd>tabprev<CR>', { silent = true })
--for telescope
vim.keymap.set('n', '<leader>ff', function () require('telescope.builtin').find_files() end)
vim.keymap.set('n', '<leader>fg', function () require('telescope.builtin').live_grep() end)
vim.keymap.set('n', '<leader>fb', function () require('telescope.builtin').buffers() end)
vim.keymap.set('n', '<leader>fh', function () require('telescope.builtin').help_tags() end)
vim.keymap.set('n', '<leader>fk', function () require('telescope.builtin').keymaps() end)
vim.keymap.set('n', '<leader>fc', function () require('telescope.builtin').git_bcommits() end)
vim.keymap.set('n', '<leader>ft', function () require('telescope.builtin').git_commits() end)
-- for nvim-dap
vim.keymap.set('n', '<F5>', function () require'dap'.continue() end, { silent = true })
vim.keymap.set('n', '<F10>', function () require'dap'.step_over() end, { silent = true })
vim.keymap.set('n', '<F11>', function () require'dap'.step_into() end, { silent = true })
vim.keymap.set('n', '<F12>', function () require'dap'.step_out() end, { silent = true })
vim.keymap.set('n', '<Leader>b', function () require("dap").toggle_breakpoint() end, { silent = true })
vim.keymap.set('n', '<Leader>B', function () require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { silent = true })
vim.keymap.set('n', '<Leader>lp', function () require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { silent = true }) 
vim.keymap.set('n', '<Leader>dr', function () require'dap'.repl.open() end, { silent = true })  
vim.keymap.set('n', '<Leader>dl', function () require'dap'.run_last() end, { silent = true })
-- for nvim-dap-python
vim.keymap.set('n', '<leader>dn', function () require('dap-python').test_method() end, { silent = true })
vim.keymap.set('n', '<leader>df', function () require('dap-python').test_class() end, { silent = true })
vim.keymap.set('v', '<leader>ds <ESC>', function () require('dap-python').debug_selection() end, { silent = true })
-- for nvim-dap-ui
vim.keymap.set('n', '<Leader>dt',function () require("dapui").toggle() end)
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
