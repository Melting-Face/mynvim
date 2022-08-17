require('plugins')
require('nvimTreeSitter')
require('nvimGitSigns')
require('nvimCmp')
require('nvimDap')
require('nvimNotify')

vim.cmd[[colorscheme tokyonight]]
vim.g.mapleader = ','
vim.g.indent_guides_auto_colors = 1
vim.g.indent_guides_enable_on_vim_startup = 1
vim.g.minimap_width = 10
vim.g.minimap_auto_start_win_enter = 1
vim.g.minimap_block_filetypes = { 'gitsigns', 'nvim-tree', 'tagbar', 'fzf' }
vim.g.minimap_close_filetypes = { 'alpha', 'vim-plug' }
vim.g.minimap_git_colors = 1
vim.o.nocompatible = true
vim.o.shell = 'zsh'
vim.o.autoread = true
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.colorcolumn = 89
vim.o.nu = true
vim.o.autoindent = true
vim.o.cindent = true
vim.o.ts = 2
vim.o.sts = 2
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab
vim.o.shiftwidth = 2
vim.o.smartcase = true
vim.o.smarttab = true
vim.o.smartindent = true
vim.o.cursorline = true
vim.o.showmatch = true
vim.o.ruler = true
vim.o.clipboard = 'unnamed'
vim.opt.fileencodings = 'utf8'
vim.opt.encoding = 'UTF-8'
vim.o.mouse = 'a'
vim.o.termguicolors = true
vim.o.background = 'dark'

vim.keymap.set('n', '<Leader>t', '<cmd>TagbarToggle<CR>')
vim.keymap.set('n', '<Leader>m', '<cmd>MinimapToggle<CR>')
vim.keymap.set('n', '<silent> <Leader>b', require('dap').toggle_breakpoint())
vim.keymap.set('n', '<Leader>dt <Cmd>lua require("dapui").toggle()<CR>'
vim.keymap.set('n', '<Leader>n', '<cmd>NvimTreeToggle<CR>')
vim.keymap.set('n', '<Leader>rn', '<cmd>NvimTreeRefresh<CR>')
vim.keymap.set('n', '<silent>b[', '<cmd>bn<CR>')
vim.keymap.set('n', '<silent>b]', '<cmd>bp<CR>')
vim.keymap.set('n', '<Leader>bdd', '<cmd>bdelete<CR>')
vim.keymap.set('n', '<Leader>bh', '<cmd>sb<CR>')
vim.keymap.set('n', '<Leader>bv', '<cmd>vs<CR>')
vim.keymap.set('n', '<Leader>bda', '<cmd>bufdo bd<CR>')
vim.keymap.set('n', '<Leader>tn', '<cmd>tabnew<CR>')
vim.keymap.set('n', '<Leader>td', '<cmd>tabclose<CR>')
vim.keymap.set('n', '<silent>t[', '<cmd>tabnext<CR>')
vim.keymap.set('n', '<silent>t]', '<cmd>tabprev<CR>')
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files())
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep())
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers())
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags())
vim.keymap.set('n', '<Leader>fn', '<cmd>NvimTreeFindFile<CR>')
vim.keymap.set('n', '<silent> <F5>', require'dap'.continue()) 
vim.keymap.set('n', '<silent> <F10>', require'dap'.step_over()) 
vim.keymap.set('n', '<silent> <F11>', require'dap'.step_into())
vim.keymap.set('n', '<silent> <F12>', require'dap'.step_out())
vim.keymap.set('n', '<silent> <Leader>B', require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: ')))
vim.keymap.set('n', '<silent> <Leader>lp', require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')))
vim.keymap.set('n', '<silent> <Leader>dr', require'dap'.repl.open())
vim.keymap.set('n', '<silent> <Leader>dl', require'dap'.run_last())
vim.keymap.set('n', '<silent> <leader>dn', require('dap-python').test_method())
vim.keymap.set('n', '<silent> <leader>df', require('dap-python').test_class())
vim.keymap.set('v', '<silent> <leader>ds <ESC>', require('dap-python').debug_selection())
vim.keymap.set('v', '<Leader>ev', require("dapui").eval())

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
