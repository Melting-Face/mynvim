-- default shell: zsh
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
vim.o.updatetime=100
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

vim.g.mapleader = ','

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icon = 1

-- magma
vim.g.magma_automatically_open_output = false
vim.g.magma_image_provider = 'kitty'

-- vim-better-whitespace
vim.g.better_whitespace_guicolor='#C0CAF5'

-- minimap
vim.g.minimap_block_filetypes={
  'alpha',
  'dbui',
  'dbout',
  'NvimTree',
  'packer',
}
