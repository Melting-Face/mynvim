#!/bin/bash

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "git clone tpm ..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# brew install go
brew install lua
brew install tmux
brew install node
brew install python
brew install ripgrep
# brew install luarocks
# brew install delve
# brew install rust
# brew install jq

ln -f "$PWD/tmux.conf" "$HOME/.tmux.conf"
tmux source-file "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/nvim"
ln -f "$PWD/init.lua" "$HOME/.config/nvim/init.lua"
ln -f "$PWD/lua" "$HOME/.config/nvim/lua"
# ln -sf "$PWD/ftplugin" "$HOME/.config/nvim/ftplugin"

nvim --headless "+Lazy! sync" +qa
