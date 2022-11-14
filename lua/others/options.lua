-- default shell: zsh
vim.g.mapleader = ','
vim.o.shell = 'zsh'
vim.o.autoread = true
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.colorcolumn = "89"
vim.o.nu = true
vim.o.autoindent = true
vim.o.cindent = true
vim.o.ts = 2
vim.o.sts = 2
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.smartcase = true
vim.o.smarttab = true
vim.o.smartindent = true
vim.o.cursorline = true
vim.o.showmatch = true
vim.o.ruler = true
vim.o.clipboard = 'unnamed'
vim.o.fileencodings = 'utf8'
vim.o.encoding = 'UTF-8'
vim.o.timeoutlen=800
-- mouse option is 'all'
vim.o.mouse = 'a'
-- termguicolor option is true
vim.o.termguicolors = true
-- background is dark
vim.o.background = 'dark'
vim.opt.textwidth=0
vim.opt.wrapmargin=0
vim.opt.wrap = true
vim.opt.linebreak = true

vim.opt.list = true
vim.opt.listchars:append "eol:↴"

vim.g.minimap_width = 10
vim.g.minimap_auto_start_win_enter = 1
vim.g.minimap_block_filetypes = { 'gitsigns', 'nvim-tree', 'tagbar', 'fzf' }
vim.g.minimap_close_filetypes = { 'alpha', 'vim-plug' }
vim.g.minimap_git_colors = 1
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icon = 1
