vim.g.mapleader = ","
vim.g.maplocalleader = ";"
-- default shell: Windows는 pwsh/powershell, 그 외는 zsh가 있을 때만 zsh
if vim.fn.has("win32") == 1 then
  -- :help shell-powershell / shell-pwsh 권장값 (shellpipe에는 %s가 하나만 허용됨)
  local is_pwsh = vim.fn.executable("pwsh") == 1
  vim.o.shell = is_pwsh and "pwsh" or "powershell"
  vim.o.shelltemp = false
  vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
    .. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
    .. "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  if is_pwsh then
    vim.o.shellcmdflag = vim.o.shellcmdflag .. "$PSStyle.OutputRendering = 'PlainText';"
    vim.env.__SuppressAnsiEscapeSequences = 1
  end
  vim.o.shellpipe = "> %s 2>&1"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
elseif vim.fn.executable("zsh") == 1 then
  vim.o.shell = "zsh"
end
vim.o.autoread = true
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.nu = true
vim.o.autoindent = true
vim.o.sts = 2
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.smartcase = true
vim.o.smarttab = true
vim.o.cursorline = false
vim.o.showmatch = true
vim.o.ruler = true
vim.o.clipboard = "unnamedplus"
-- BOM, UTF-8 순으로 시도하고 실패하면 cp949(euc-kr)로 연다
vim.o.fileencodings = "ucs-bom,utf-8,cp949,latin1"
vim.o.updatetime = 100
vim.o.timeoutlen = 2500
local undodir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undodir, "p")
vim.o.undodir = undodir
vim.o.undofile = true
-- mouse는 hit-enter/more 프롬프트에서만 사용
vim.o.mouse = "r"
-- termguicolor option is true
vim.o.termguicolors = true
-- background is dark
vim.o.background = "dark"
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.wrap = true
vim.opt.linebreak = true

vim.opt.list = true
vim.opt.listchars:append("eol:↴")

vim.g.ftplugin_sql_omni_key = "<C-;>"
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icon = 1
vim.g.better_whitespace_guicolor = "#C0CAF5"
