UNAME="$(uname -s)"
STARTPATH="$(pwd)"

function install_manager() {
  echo "check packer ..."
  if [ ! -d "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" ]; then 
    echo "git clone packer ..."
    git clone --depth 1 "https://github.com/wbthomason/packer.nvim" \
    "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
  fi

  echo "check tpm ..."
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "git clone tpm ..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
}

function install_package() {
  PREFIX=""
  if [ $UNAME == "Darwin" ]; then
    PREFIX=brew
  elif [ $UNAME == "Linux" ]; then
    PREFIX=apt-get
  else
    echo "check to kurnel: $UNAME"
    exit 9
  fi

  $PREFIX install neovim
  $PREFIX install tmux
  $PREFIX install ripgrep
  $PREFIX install go
  $PREFIX install lua
  $PREFIX install node
  $PREFIX install python
  $PREFIX install code-minimap
  $PREFIX install lazygit
  $PREFIX install lazydocker
  $PREFIX install jesseduffield/lazynpm/lazynpm
  $PREFIX install delve
  $PREFIX install llvm
  $PREFIX install rust
  pip3 install neovim
  pip3 install debugpy
  pip3 install flake8
  pip3 install pytest
  pip3 install ipython
}

function create_symlink() {
  WORKDIR=$(pwd)
  if [ ! -f "$HOME/.tmux.conf" ]; then
    ln -s "$WORKDIR/tmux.conf" "$HOME/.tmux.conf" 
    tmux source-file "$HOME/.tmux.conf"
  fi

  if [ ! -f "$HOME/.config/nvim/init.lua" ]; then
    mkdir -p "$HOME/.config/nvim"
    ln -s "$WORKDIR/init.lua" "$HOME/.config/nvim/init.lua"
  fi

  if [ ! -d "$HOME/.config/nvim/lua" ]; then
    mkdir -p "$HOME/.config/nvim"
    ln -s "$WORKDIR/lua" "$HOME/.config/nvim/lua"
  fi

  if [ ! -d "$HOME/.config/nvim/ftplugin" ]; then
    mkdir -p "$HOME/.config/nvim"
    ln -s "$WORKDIR/ftplugin" "$HOME/.config/nvim/ftplugin"
  fi

}

function install_plugins() {
  nvim +PackerSync 
} 

if [ $1 == 'all' ]; then
  install_package;
  install_manager;
  create_symlink;
  install_plugins;
else
  echo "install manager [1]"
  echo "install package [2]"
  echo "create symlink [3]"
  echo "install plugins [4]"

  read -p "select option :" OPT

  case $OPT in
    1) install_manager;;
    2) install_package;;
    3) create_symlink;;
    4) install_plugins;;
  esac
fi
