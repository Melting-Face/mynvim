call plug#begin('~/.vim')

" airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'

" nvim-treesitter
Plug 'nvim-treesitter/nvim-treesitter'

" NvimTree
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'

" Nerdcommenter
Plug 'preservim/nerdcommenter'

" ctrlp
Plug 'kien/ctrlp.vim'

" syntastic
Plug 'tpope/vim-pathogen'
Plug 'vim-syntastic/syntastic'

" surround
Plug 'tpope/vim-surround'
" repeat
Plug 'tpope/vim-repeat'

" git
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'
Plug 'APZelos/blamer.nvim'

" multi cursor
Plug 'mg979/vim-visual-multi'

" tokyonight theme
Plug 'folke/tokyonight.nvim'

" startify
Plug 'mhinz/vim-startify'

" minimap
Plug 'wfxr/minimap.vim'

" ack
Plug 'mileszs/ack.vim'

" eslint
Plug 'eslint/eslint'

" tagbar
Plug 'preservim/tagbar'

" csv
Plug 'chrisbra/csv.vim'

" indent
Plug 'michaeljsmith/vim-indent-object'
Plug 'nathanaelkane/vim-indent-guides'

" lsp
Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'

" nvim-cmp
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" vim spector
Plug 'puremourning/vimspector'

call plug#end()
filetype plugin indent on

execute pathogen#infect()

lua <<EOF
  vim.cmd[[colorscheme tokyonight]]
	require('nvim-lsp-installer').setup {}
	require'nvim-tree'.setup {}
	require'nvim-treesitter.configs'.setup { 
    ensure_installed = { 
      'css',
      'graphql',
      'html',
      'java',
      'javascript',
      'json',
      'kotlin',
      'lua',
      'python',
      'vim',
      'sql',
      'tsx',
      'typescript',
      'yaml',
    },
    sync_install = true,
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  }

  -- setup nvim-lspconfig
  local opts = { noremap=true, silent=true }
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

  local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
  end

  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users. 
      end,
    }, 
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  local languages = {
    'tsserver',
    'kotlin_language_server',
    'dockerls',
    'jedi_language_server',
    'yamlls',
    'jsonls',
    'jdtls',
  }

  for idx, language in ipairs(languages) do 
    require('lspconfig')[language].setup { on_attach = on_attach, capabilities = capabilities }
  end
EOF

set nocompatible
" zsh
set shell=zsh
" automatic read
set autoread
" highlight search
set hlsearch
" when you search keyword, ignore case
" set ignorecase

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

let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_typescript_checkers = ['eslint']
let g:syntastic_python_checkers = ['flake8']

function! SyntasticCheckHook(errors)
  if !empty(a:errors)
    let g:syntastic_loc_list_height = min([len(a:errors), 1])
  endif
endfunction

" ctrlp ignored git node_modules DS_Store
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git\|__pycache__'  
let g:airline_theme = 'onedark'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#ctrlp#enabled = 1
let g:airline#extensions#csv#enabled = 1
let g:airline_powerline_fonts = 1

" git blame
let g:blamer_date_format = '%y/%m/%d %H:%M'
let g:blamer_delay = 250

" Nerdcommenter
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_java = 1
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

let g:indent_guides_auto_colors = 1
let g:indent_guides_enable_on_vim_startup = 1

" minimap
let g:minimap_width = 10
let g:minimap_auto_start_win_enter = 1
let g:minimap_block_filetypes = ['fugitive', 'nvim-tree', 'tagbar', 'ctrlp' ]
let g:minimap_close_filetypes = ['startify', 'vim-plug']
let g:minimap_git_colors =  1

" Ack
let g:ackhighlight = 1
let g:ack_autoclose = 1

" vimspector
let g:vimspector_enable_mappings = 'HUMAN'
let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-node-debug2', 'vscode-java-debug' ]
let g:vimspector_configurations = {
  \"Python: Launch": {
    \"adapter": "debugpy",
    \"filetypes": [ "python" ],
    \"configuration": {
      \"name": "Python", 
      \"type": "python",
      \"request": "launch",
      \"python": "/usr/local/bin/python3",
      \"stopOnEntry": v:true,
      \"console": "externalTerminal",
      \"debugOptions": [],
      \"program": "${file}",
      \"cwd": "${workspaceRoot}"
    \}
  \},
  \"Node: Launch": {
    \"adapter": "vscode-node",
    \"filetypes": [ "javascript", "typescript" ],
    \"configuration": {
      \"name": "Node",
      \"request": "launch",
      \"protocol": "auto",
      \"stopOnEntry": v:true,
      \"console": "integratedTerminal",
      \"program": "${file}",
      \"cwd": "${workspaceRoot}"
    \}
  \},
  \"Java: Launch": {
    \"adapter": "vscode-java",
    \"filetypes": [ "java" ],
    \"configuration": {
      \"request": "attach",
      \"hostName": "${host}",
      \"port": "${port}",
      \"sourcePaths": [
        \"${workspaceRoot}/src/main/java",
        \"${workspaceRoot}/src/test/java"
      \]
    \}
  \}
\}

let mapleader = ","

if has("syntax")
  syntax on
endif

" Ack
nnoremap <Leader>fj :Ack --js
nnoremap <Leader>fp :Ack --py

" tagbar
nnoremap <Leader>t :TagbarToggle<CR>

" git blame
nnoremap <Leader>b :BlamerToggle<CR>

" minimap
nnoremap <Leader>m :MinimapToggle<CR>

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

nnoremap <C-l> :NvimTreeToggle<CR>
nnoremap <C-r> :NvimTreeRefresh<CR>
nnoremap <C-f> :NvimTreeFindFile<CR>

nnoremap Ω :bprev<CR>
nnoremap ≈ :bnext<CR>
nnoremap ç :bdelete<CR>
nnoremap ˙ :sb<CR>
nnoremap √ :vs<CR>
nnoremap ˜ :tabnew<CR>
nnoremap ∂ :tabclose<CR>
nnoremap å :tabprev<CR>
nnoremap ß :tabnext<CR>
nnoremap ¢ :bufdo bd<CR>

nnoremap <C-p> :Files<CR>

" for normal mode - the word under the cursor
nnoremap <Leader>di <Plug>VimspectorBalloonEval
" for visual mode, the visually selected text
xnoremap <Leader>di <Plug>VimspectorBalloonEval
