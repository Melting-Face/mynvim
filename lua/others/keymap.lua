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
vim.keymap.set('n', 'b[', '<cmd>bn<CR>', { silent = true })
vim.keymap.set('n', 'b]', '<cmd>bp<CR>', { silent = true })
vim.keymap.set('n', '<Leader>bdd', '<cmd>bdelete<CR>')
vim.keymap.set('n', '<Leader>bh', '<cmd>sb<CR>')
vim.keymap.set('n', '<Leader>bv', '<cmd>vs<CR>')
vim.keymap.set('n', '<Leader>bda', '<cmd>bufdo bd<CR>')

-- for tab
vim.keymap.set('n', '<Leader>tn', '<cmd>tabnew<CR>')
vim.keymap.set('n', '<Leader>td', '<cmd>tabclose<CR>')
vim.keymap.set('n', '<silent>t[', '<cmd>tabnext<CR>')
vim.keymap.set('n', '<silent>t]', '<cmd>tabprev<CR>')

--for telescope
vim.keymap.set('n', '<leader>ff', function () require('telescope.builtin').find_files() end)
vim.keymap.set('n', '<leader>fg', function () require('telescope.builtin').live_grep() end)
vim.keymap.set('n', '<leader>fb', function () require('telescope.builtin').buffers() end)
vim.keymap.set('n', '<leader>fh', function () require('telescope.builtin').help_tags() end)

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


-- for fugitive(git)
vim.keymap.set('n', '<Leader>ga', '<cmd>G add')
vim.keymap.set('n', '<Leader>gaa', '<cmd>G add .<cr>')
vim.keymap.set('n', '<Leader>gb', '<cmd>:G branch<CR>')
vim.keymap.set('n', '<Leader>gbd', '<cmd>G branch -d')
vim.keymap.set('n', '<Leader>gcm', '<cmd>G commit -m')
vim.keymap.set('n', '<Leader>gco', '<cmd>G checkout')
vim.keymap.set('n', '<Leader>gl', '<cmd>G pull')
vim.keymap.set('n', '<Leader>gp', '<cmd>G push<CR>')
vim.keymap.set('n', '<Leader>grh', '<cmd>G reset HEAD<CR>')
vim.keymap.set('n', '<Leader>grs', '<cmd>G restore')
vim.keymap.set('n', '<Leader>gst', '<cmd>G status<CR>')
