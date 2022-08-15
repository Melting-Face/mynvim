UNAME="$(uname -s)"
STARTPATH="$(pwd)"

function install_manager() {
  echo "check vim manager ..."
  if [ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ]; then 
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  fi

  echo "check tpm manager ..."
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
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

  `$PREFIX install neovim`
  `$PREFIX install tmux`
  `$PREFIX install universal-ctags`
  `$PREFIX install ack`
  `$PREFIX install lua`
  `$PREFIX install n`
  `$PREFIX install code-minimap`
  `pip3 install neovim`
}

# node
function dap_node() {
  echo "check to nvim_damp node ..."
  if [ ! -d "$HOME/dev/microsoft/vscode-node-debug2" ]; then
    mkdir -p "$HOME/dev/microsoft" &&
    git clone "https://github.com/microsoft/vscode-node-debug2.git" "$HOME/dev/microsoft/vscode-node-debug2" &&
    cd "$HOME/dev/microsoft/vscode-node-debug2" &&
    npm i &&
    NODE_OPTIONS=--no-experimental-fetch npm run build
  fi
  cd $STARTPATH
}

# python
function dap_python() {
  which pip3 && pip3 install debugpy
  which pip && pip install debugpy
}

function create_symlink() {
  WORKDIR=$(pwd)
  if [ ! -f "$HOME/.tmux.conf" ]; then
    ln -s "$WORKDIR/tmux.conf" "$HOME/.tmux.conf" 
    tmux source-file "$HOME/.tmux.conf"
  fi

  if [ ! -f "$HOME/.config/nvim/init.vim" ]; then
    mkdir -p "$HOME/.config/nvim" 
    ln -s "$WORKDIR/init.vim" "$HOME/.config/nvim/init.vim"
  fi
}

echo "install manager [1]"
echo "install package [2]"
echo "set nvim-dap-node [3]" 
echo "set nvim-dap-python [4]"
echo "create symlink [5]"

read -p "select option :" OPT

case $OPT in
  1) install_manager;;
  2) install_package;;
  3) dap_node;;
  4) dap_python;;
  5) create_symlink;;
esac
