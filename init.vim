require('plugins')
require('nvimTreeSitter')
require('nvimGitSigns')
require('nvimCmp')
require('nvimDap')
require('nvimNotify')

  vim.cmd[[colorscheme tokyonight]]

set nocompatible
" zsh
set shell=zsh
" automatic read
set autoread
" highlight search
set hlsearch
" when you search keyword, ignore case
set ignorecase
" column Line
set colorcolumn=89

" Line Number
set nu

set autoindent
set cindent

" tab space = 2
set ts=2
set sts=2
set shiftwidth=2
set tabstop=2
set expandtab
set shiftwidth=2

" smart setting
set smartcase
set smarttab
set smartindent

set cursorline

set showmatch

set ruler

set clipboard=unnamed

set fileencodings=utf8
set encoding=UTF-8

" use mouse
set mouse=a

set wildignore+=*/tmp/*,*.so,*.swp,*.zip

set termguicolors " this variable must be enabled for colors to be applied properly

set background=dark

let g:indent_guides_auto_colors = 1
let g:indent_guides_enable_on_vim_startup = 1

" minimap
let g:minimap_width = 10
let g:minimap_auto_start_win_enter = 1
let g:minimap_block_filetypes = ['gitsigns', 'nvim-tree', 'tagbar', 'fzf' ]
let g:minimap_close_filetypes = ['alpha', 'vim-plug']
let g:minimap_git_colors =  1

let mapleader = ","

if has("syntax")
  syntax on
endif

" ========= toggle =========
" tagbar
nnoremap <Leader>t :TagbarToggle<CR>
" minimap
nnoremap <Leader>m :MinimapToggle<CR>
" dap
nnoremap <silent> <Leader>b <Cmd>lua require'dap'.toggle_breakpoint()<CR>
" dap ui
nnoremap <Leader>dt <Cmd>lua require("dapui").toggle()<CR>
" nvim-tree
nnoremap <Leader>n :NvimTreeToggle<CR>
" ==========================
"
" nvim-tree
nnoremap <Leader>rn :NvimTreeRefresh<CR>
" buf
nnoremap <silent>b[ :bn<CR>
nnoremap <silent>b] :bp<CR>
nnoremap <Leader>bdd :bdelete<CR>
nnoremap <Leader>bh :sb<CR>
nnoremap <Leader>bv :vs<CR>
nnoremap <Leader>bda :bufdo bd<CR>
" tab
nnoremap <Leader>tn :tabnew<CR>
nnoremap <Leader>td :tabclose<CR>
nnoremap <silent>t[ :tabnext<CR>
nnoremap <silent>t] :tabprev<CR>
" telescope
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <Leader>fn :NvimTreeFindFile<CR>
" nvim-dap
nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
" nvim-dap-python
nnoremap <silent> <leader>dn :lua require('dap-python').test_method()<CR>
nnoremap <silent> <leader>df :lua require('dap-python').test_class()<CR>
vnoremap <silent> <leader>ds <ESC> :lua require('dap-python').debug_selection()<CR>
" nvim-dap-ui
vnoremap <Leader>ev <Cmd>lua require("dapui").eval()<CR>
" Fugtive
nnoremap <Leader>ga :G add
nnoremap <Leader>gaa :G add .<CR>
nnoremap <Leader>gb :G branch<CR>
nnoremap <Leader>gbd :G branch -d
nnoremap <Leader>gcm :G commit -m
nnoremap <Leader>gco :G checkout
nnoremap <Leader>gl :G pull
nnoremap <Leader>gp :G push<CR>
nnoremap <Leader>grh :G reset HEAD<CR>
nnoremap <Leader>grs :G restore
nnoremap <Leader>gst :G status<CR>
