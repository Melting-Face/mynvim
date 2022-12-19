## TIP

- `<c-n>`: auto complete

## Install

### nvim + tmux
```shell
sh nvim.sh all
# or
sh nvim.sh
```

## Plugins to be installed

### tmux

- [tpm](https://github.com/tmux-plugins/tpm)

- [sensible](https://github.com/tmux-plugins/tmux-sensible)

- [one dark](https://github.com/odedlaz/tmux-onedark-theme)

- [cpu](https://github.com/tmux-plugins/tmux-cpu)

- [battery](https://github.com/tmux-plugins/tmux-battery)

- [prefix highlight](https://github.com/tmux-plugins/tmux-prefix-highlight)

## Attempt to install

### install kotlin debug
```shell
# gradle
brew install gradle
# sdk man
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install kotlin

git clone https://github.com/fwcd/kotlin-debug-adapter
./gradlew :adapter:installDist
```

### install c++ debug
```shell
# llvm
brew install llvm
```
