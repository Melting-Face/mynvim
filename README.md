# mynvim

Neovim(+ tmux) 개인 설정입니다. macOS, Linux, WSL, Windows에서 스크립트 한 번으로 설치합니다.

## 목차

1. [소개](#소개)
2. [터미널 준비(WezTerm)](#터미널-준비wezterm)
3. [빠른 시작](#빠른-시작)
4. [설치 옵션](#설치-옵션)
5. [설치되는 것](#설치되는-것)
6. [주요 키맵 및 팁](#주요-키맵-및-팁)
7. [플러그인 목록](#플러그인-목록)
8. [문제 해결](#문제-해결)
9. [백업 복구 방법](#백업-복구-방법)

## 소개

이 레포는 Neovim 설정(`init.lua`, `lua/`), tmux 설정(`tmux.conf`), WezTerm 설정(`wezterm.lua`)을 담고 있습니다.
설치 스크립트는 필요한 도구를 설치하고, 이 레포를 설정 경로에 연결하고, 플러그인까지 동기화합니다.

**이 구성은 WezTerm 터미널 환경을 기준으로 합니다.** WezTerm 기준으로 검증했으며, 다른 터미널은 동작할 수 있지만 보장하지 않습니다.

| 환경 | 설치 스크립트 | 패키지 관리자 |
| --- | --- | --- |
| macOS | [`install.sh`](install.sh) | Homebrew |
| Linux (Debian/Ubuntu 계열) | [`install.sh`](install.sh) | apt |
| Linux (Fedora 계열) | [`install.sh`](install.sh) | dnf |
| Linux (Arch 계열) | [`install.sh`](install.sh) | pacman |
| WSL | [`install.sh`](install.sh) | apt, dnf, pacman 중 감지된 것 |
| Windows (네이티브) | [`install.ps1`](install.ps1) | winget |

Neovim은 0.11 이상이 필요합니다. 더 낮거나 없으면 스크립트가 설치하거나 올립니다.

## 터미널 준비(WezTerm)

먼저 WezTerm을 설치하세요.

| OS | 설치 방법 |
| --- | --- |
| macOS | `brew install --cask wezterm` |
| Windows | `winget install wez.wezterm` |
| Linux | [공식 설치 문서](https://wezterm.org/install/linux.html)를 따르세요 |

알아둘 점은 다음과 같습니다.

- **폰트 설치는 필요 없습니다.** WezTerm에 JetBrains Mono와 Nerd Font 심볼이 내장되어 있습니다.
- **설정 연결**: 설치 스크립트는 WezTerm이 감지될 때만 설정을 연결합니다.
    - macOS, Linux: `~/.wezterm.lua`를 이 레포의 [`wezterm.lua`](wezterm.lua)로 링크합니다.
    - Windows: 파일 링크 대신 사용자 환경변수 `WEZTERM_CONFIG_FILE`을 설정합니다.
    - WezTerm을 나중에 설치했다면 설치 스크립트를 다시 실행하세요.
- **Windows 기본 셸**은 PowerShell 7(`pwsh.exe`)입니다. 설치 스크립트가 필수 항목으로 함께 설치합니다(`Microsoft.PowerShell`).
- **WSL 사용자**는 WezTerm을 Windows 쪽에 설치하고 WSL 도메인으로 접속합니다.
  [`wezterm.lua`](wezterm.lua)의 주석 처리된 `default_domain` 예시(`config.default_domain = "WSL:Ubuntu"`)를 풀고 배포판 이름을 맞추세요.
  WSL 안의 설치 스크립트는 `~/.wezterm.lua`를 만들지 않습니다.

## 빠른 시작

**clone한 경로가 곧 설정 경로입니다. 설치 후에는 폴더를 옮기지 마세요.** 설정이 이 폴더를 가리키는 링크이기 때문입니다.
설정 경로(`~/.config/nvim`, `%LOCALAPPDATA%\nvim`) 안에 clone하지 말고 `~/mynvim`처럼 별도 폴더에 clone하세요.

### macOS

[Homebrew](https://brew.sh)가 먼저 필요합니다. `git`이 없다면 `xcode-select --install` 또는 `brew install git`으로 설치하세요.

```shell
git clone https://github.com/Melting-Face/mynvim.git ~/mynvim
~/mynvim/install.sh
```

### Linux / WSL

`git`이 없다면 배포판에 맞는 명령으로 먼저 설치하세요.

```shell
sudo apt install -y git          # Debian/Ubuntu, WSL
sudo dnf install -y git          # Fedora
sudo pacman -S --needed git      # Arch
```

```shell
git clone https://github.com/Melting-Face/mynvim.git ~/mynvim
~/mynvim/install.sh
```

### Windows (PowerShell)

관리자 권한은 필요 없습니다. winget(App Installer)이 먼저 필요합니다. 없다면 https://aka.ms/getwinget 에서 설치하세요.

`git`이 없다면 먼저 설치하고, **새 PowerShell 창을 연 뒤** 다음 단계로 넘어가세요(새 창이어야 `git`이 PATH에 잡힙니다).

```powershell
winget install Git.Git
```

```powershell
git clone https://github.com/Melting-Face/mynvim.git $HOME\mynvim
powershell -ExecutionPolicy Bypass -File $HOME\mynvim\install.ps1
```

선택 항목을 지정하지 않고 터미널에서 직접 실행하면, 항목별로 설치 여부(`y/N`)를 묻습니다.
무엇이 실행되는지 먼저 보려면 `--dry-run`(Windows는 `-DryRun`)을 붙이세요.

```shell
~/mynvim/install.sh --dry-run --yes
```

```powershell
cd $HOME\mynvim
powershell -ExecutionPolicy Bypass -File .\install.ps1 -DryRun -Yes
```

### 설치 확인

설치가 끝나면 **새 터미널**을 열고 `nvim`을 실행하세요. 플러그인은 설치 중에 이미 동기화됩니다.
처음 실행할 때 mason이 LSP 서버를 백그라운드로 설치하므로 1~2분 정도 기다리세요.
문제가 있으면 nvim 안에서 `:checkhealth`로 원인을 확인할 수 있습니다.

### 업데이트

```shell
cd ~/mynvim
git pull
./install.sh --yes
```

```powershell
cd $HOME\mynvim
git pull
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Yes
```

플러그인만 갱신하려면 nvim 안에서 `:Lazy sync`를 실행하세요.

## 설치 옵션

| bash (`install.sh`) | PowerShell (`install.ps1`) | 설명 |
| --- | --- | --- |
| `--with <목록>` | `-With <목록>` | 선택 항목을 쉼표로 지정합니다. 예: `--with tmux,rust` |
| `--all` | `-All` | 선택 항목을 모두 설치합니다. Windows는 tmux를 제외합니다 |
| `--yes` | `-Yes` | 질문 없이 진행합니다. 선택 항목이 없으면 필수만 설치합니다 |
| `--dry-run` | `-DryRun` | 실행할 명령만 출력하고 아무것도 바꾸지 않습니다 |
| `--help` | (`Get-Help .\install.ps1`) | 도움말을 출력합니다 |

예시입니다.

```shell
# macOS, Linux, WSL
./install.sh --with tmux,rust --yes
./install.sh --all --yes
```

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File .\install.ps1 -With rust,lua -Yes
powershell -ExecutionPolicy Bypass -File .\install.ps1 -All -Yes
```

알 수 없는 항목 이름을 쓰면 오류(종료 코드 2)로 끝납니다.

### 선택 항목

선택하지 않은 도구는 설치하지 않습니다.

| 항목 | 설치 내용 |
| --- | --- |
| `tmux` | tmux, 플러그인 관리자 tpm(`~/.tmux/plugins/tpm`), `~/.tmux.conf` 링크. **Windows 네이티브는 지원하지 않습니다** (대신 WezTerm이 tmux와 같은 키로 패널·탭을 제공합니다. [docs/tmux.md](docs/tmux.md#windows-네이티브-wezterm-멀티플렉서) 참고) |
| `go` | Go 툴체인 |
| `rust` | macOS, Linux, WSL: rustup (공식 설치 스크립트). Windows: `Rustlang.Rustup` |
| `java` | JDK 21 |
| `lua` | Lua |

## 설치되는 것

### 필수

항상 설치됩니다. 이미 있으면 건너뜁니다.

| 도구 | macOS (brew) | Debian/Ubuntu, WSL (apt) | Fedora (dnf) | Arch (pacman) | Windows (winget) |
| --- | --- | --- | --- | --- | --- |
| Neovim 0.11+ | `neovim` (0.11 미만일 때) | 공식 tarball | 공식 tarball | 공식 tarball | `Neovim.Neovim` |
| Git | `git` | `git` | `git` | `git` | `Git.Git` |
| ripgrep | `ripgrep` | `ripgrep` | `ripgrep` | `ripgrep` | `BurntSushi.ripgrep.MSVC` |
| Node.js 18+ | `node` | `nodejs`, `npm` | `nodejs` | `nodejs`, `npm` | `OpenJS.NodeJS.LTS` |
| Python | `python` | `python3`, `python3-pip`, `python3-venv` | `python3`, `python3-pip` | `python`, `python-pip` | `Python.Python.3.12` |
| C 컴파일러 (treesitter용) | Xcode CLT (`xcode-select --install`) | `build-essential` | `gcc`, `make` | `base-devel` | `zig.zig` |
| PowerShell 7 (WezTerm 기본 셸) | | | | | `Microsoft.PowerShell` |
| 기타 | `gnu-sed` | `curl`, `unzip`, `xz-utils` | `curl`, `unzip`, `glibc-gconv-extra` (cp949 등 문자셋 변환) | `curl`, `unzip` | |
| 클립보드 | 기본 제공 | `xclip` 또는 `wl-clipboard` | 같음 | 같음 | 기본 제공 |

- Linux에서 Neovim이 0.11 미만이면 공식 tarball을 `~/.local/opt/nvim`에 풀고 `~/.local/bin/nvim`으로 링크합니다.
  이미 `~/.local/bin/nvim`이 0.11 이상이면 다시 받지 않습니다.
- Linux에서 패키지로 받은 Node.js가 없거나 18 미만이면 공식 LTS(v22) tarball을 체크섬 검증 후 `~/.local/opt/node`에 풀고
  `node`, `npm`, `npx`를 `~/.local/bin`에 링크합니다. macOS는 brew의 `node`를 쓰며 18 미만이면 경고만 합니다.
- `~/.local/bin`에 설치했는데 셸에서 다른 `nvim`/`node`가 먼저 잡히면 경고를 출력합니다([문제 해결](#문제-해결) 참고).
- Wayland 세션이면 `wl-clipboard`, 아니면 `xclip`을 설치합니다. WSL은 `win32yank.exe`를 씁니다([문제 해결](#문제-해결) 참고).
- macOS의 C 컴파일러는 스크립트가 설치하지 않고 안내만 합니다.

### 선택

| 항목 | macOS (brew) | Debian/Ubuntu, WSL (apt) | Fedora (dnf) | Arch (pacman) | Windows (winget) |
| --- | --- | --- | --- | --- | --- |
| `tmux` | `tmux` | `tmux` | `tmux` | `tmux` | 지원 안 함 |
| `go` | `go` | `golang-go` | `golang` | `go` | `GoLang.Go` |
| `rust` | rustup | rustup | rustup | rustup | `Rustlang.Rustup` |
| `java` | `temurin@21` (cask) | `openjdk-21-jdk` | `java-21-openjdk-devel` | `jdk21-openjdk` | `EclipseAdoptium.Temurin.21.JDK` |
| `lua` | `lua` | `lua5.4` | `lua` | `lua` | `DEVCOM.Lua` |

### 설정 연결

| 대상 | 위치 |
| --- | --- |
| Neovim | macOS, Linux, WSL: `~/.config/nvim` (`XDG_CONFIG_HOME`이 있으면 그 아래). Windows: `%LOCALAPPDATA%\nvim` (디렉터리 정션) |
| tmux | `~/.tmux.conf` (`tmux` 선택 시) |
| WezTerm | macOS, Linux: `~/.wezterm.lua`. Windows: 환경변수 `WEZTERM_CONFIG_FILE` (WezTerm 감지 시) |

이미 있는 대상은 지우지 않고 `<대상>.bak.<YYYYMMDD-HHMMSS>`로 이름을 바꿔 백업합니다.
이미 이 레포를 가리키고 있으면 아무것도 하지 않으므로, 스크립트를 다시 실행해도 안전합니다.

## 주요 키맵 및 팁

leader 키는 `,`, localleader 키는 `;`입니다. 모든 키맵은 `,fk`(Telescope keymaps)나 `which-key`로 확인할 수 있습니다.

### 팁

- **자동 완성**: 입력 중 `<C-n>`으로 nvim-cmp 후보를 엽니다.
- **정렬 (Tabular)**: visual 모드에서 `:Tab /:`를 실행하면 `:` 기준으로 정렬합니다. [Tabular cheatsheet](https://devhints.io/tabular)
- **undo 기록**: 파일을 닫았다 다시 열어도 undo 기록이 남습니다(`undofile`). `;u`로 undo tree를 열어 이전 상태로 돌아갈 수 있습니다.
- **한글 인코딩**: cp949(euc-kr)로 저장된 파일도 자동으로 감지해 엽니다. 저장할 때는 원래 인코딩을 유지하며, UTF-8로 바꾸려면 `:set fileencoding=utf-8`을 실행한 뒤 저장합니다.
- **Python 린트 (ruff)**: ruff 언어 서버가 기본 규칙에 더해 `B`, `PD`, `NPY`, `UP` 등을 함께 검사합니다. 규칙 목록은 [`lua/configs/lsp_servers.lua`](lua/configs/lsp_servers.lua)의 `extendSelect`에 있으며, 에디터 설정이 프로젝트의 `pyproject.toml`보다 우선합니다.
- **Git (Fugitive)**: `:G`로 상태 창을 열고 다음 키를 씁니다.

  | 키 | 동작 |
  | --- | --- |
  | `s` | stage (`git add`) |
  | `u` | unstage (`git reset`) |
  | `cc` | commit |
  | `:G push` | push |

### 자주 쓰는 키

| 키 | 동작 |
| --- | --- |
| `,ff` | 파일 찾기 (Telescope) |
| `,fs` | 내용 검색 (live grep) |
| `,fk` | 키맵 검색 |
| `;n` | 파일 트리 토글 (nvim-tree) |
| `,nf` | 파일 트리에서 현재 파일 찾기 |
| `;u` | undo tree 토글 |
| `;d` | DB UI 토글 |
| `,ng` | Neogit |
| `,hb` | 현재 줄 git blame 토글 |
| `,1` ~ `,9` | N번째 버퍼로 이동 |
| `[b`, `]b` | 이전, 다음 버퍼 |
| `[t`, `]t` | 이전, 다음 탭 |
| `<space>bx` | 버퍼 닫기 |
| `<space>tn`, `<space>tx` | 새 탭, 탭 닫기 |
| `gd`, `gr`, `K` | 정의로 이동, 참조 보기, 문서 보기 (LSP) |
| `,ca` | 코드 액션 |
| `,ac` | Claude Code 토글 |

## 플러그인 목록

### nvim

[`lua/plugins.lua`](lua/plugins.lua) 기준이며, lazy.nvim이 관리합니다.
버전 고정 파일(`lazy-lock.json`)은 커밋하지 않습니다.

**UI·테마**: [catppuccin](https://github.com/catppuccin/nvim), [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim), [bufferline.nvim](https://github.com/akinsho/bufferline.nvim), [scope.nvim](https://github.com/tiagovla/scope.nvim), [nvim-navic](https://github.com/SmiteshP/nvim-navic), [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim), [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons), [vim-startify](https://github.com/mhinz/vim-startify), [which-key.nvim](https://github.com/folke/which-key.nvim), [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)

**검색·이동**: [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim), [hop.nvim](https://github.com/smoka7/hop.nvim), [nvim-spectre](https://github.com/nvim-pack/nvim-spectre), [nvim-bqf](https://github.com/kevinhwang91/nvim-bqf), [tmux.nvim](https://github.com/aserowy/tmux.nvim)

**편집**: [Comment.nvim](https://github.com/numToStr/Comment.nvim), [nvim-surround](https://github.com/kylechui/nvim-surround), [vim-visual-multi](https://github.com/mg979/vim-visual-multi), [tabular](https://github.com/godlygeek/tabular), [text-case.nvim](https://github.com/johmsalas/text-case.nvim), [vim-better-whitespace](https://github.com/ntpeters/vim-better-whitespace), [undotree](https://github.com/mbbill/undotree), [todo-comments.nvim](https://github.com/folke/todo-comments.nvim), [neogen](https://github.com/danymat/neogen)

**Git**: [vim-fugitive](https://github.com/tpope/vim-fugitive), [neogit](https://github.com/NeogitOrg/neogit), [diffview.nvim](https://github.com/sindrets/diffview.nvim), [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim), [git-conflict.nvim](https://github.com/akinsho/git-conflict.nvim)

**LSP·자동 완성**: [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig), [mason.nvim](https://github.com/williamboman/mason.nvim), [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim), [none-ls.nvim](https://github.com/nvimtools/none-ls.nvim), [mason-null-ls.nvim](https://github.com/jayp0521/mason-null-ls.nvim), [nvim-cmp](https://github.com/hrsh7th/nvim-cmp), [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp), [cmp-buffer](https://github.com/hrsh7th/cmp-buffer), [cmp-path](https://github.com/hrsh7th/cmp-path), [cmp-cmdline](https://github.com/hrsh7th/cmp-cmdline), [LuaSnip](https://github.com/L3MON4D3/LuaSnip), [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip), [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter), [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects), [rustaceanvim](https://github.com/mrcjkb/rustaceanvim), [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)

**디버깅 (DAP)**: [nvim-dap](https://github.com/mfussenegger/nvim-dap), [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui), [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text), [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python), [nvim-nio](https://github.com/nvim-neotest/nvim-nio)

**데이터·DB**: [vim-dadbod](https://github.com/tpope/vim-dadbod), [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui), [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion), [rainbow_csv](https://github.com/mechatroner/rainbow_csv), [csv.vim](https://github.com/chrisbra/csv.vim)

**기타**: [claudecode.nvim](https://github.com/coder/claudecode.nvim), [snacks.nvim](https://github.com/folke/snacks.nvim), [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

### tmux

tmux는 선택 항목입니다. 사용법과 tpm 플러그인 설치는 [docs/tmux.md](docs/tmux.md)를 보세요.

- [tpm](https://github.com/tmux-plugins/tpm)
- [sensible](https://github.com/tmux-plugins/tmux-sensible)
- [one dark](https://github.com/odedlaz/tmux-onedark-theme)
- [cpu](https://github.com/tmux-plugins/tmux-cpu)
- [battery](https://github.com/tmux-plugins/tmux-battery)
- [prefix highlight](https://github.com/tmux-plugins/tmux-prefix-highlight)

## 문제 해결

### PowerShell 실행 정책 오류 (Windows)

`이 시스템에서 스크립트를 실행할 수 없으므로...` 오류가 나면 실행 정책(ExecutionPolicy) 때문입니다.
빠른 시작처럼 `-ExecutionPolicy Bypass`를 붙여 실행하세요. 시스템 설정은 바뀌지 않습니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### winget 설치 중 UAC 창이 뜹니다 (Windows)

정상입니다. 일부 패키지가 관리자 승인을 요청합니다. 셸을 관리자 권한으로 열 필요는 없습니다.

### `nvim`을 찾을 수 없음, 또는 오래된 `nvim`이 실행됨 (Linux)

Neovim이나 Node.js를 tarball로 설치했다면 `~/.local/bin`이 PATH에서 **가장 앞**에 있어야 합니다.
(`/usr/bin`의 오래된 `nvim`이 먼저 잡히면 설치 스크립트가 경고를 출력합니다.) 셸 설정(`~/.bashrc`, `~/.zshrc`)에 추가하세요.

```shell
export PATH="$HOME/.local/bin:$PATH"
```

### 클립보드가 동작하지 않음

- **Linux**: `xclip`(X11) 또는 `wl-clipboard`(Wayland)가 필요합니다. 스크립트가 설치하지만, 세션 종류를 바꿨다면 직접 설치하세요.
- **WSL**: Windows 쪽에 `win32yank.exe`가 필요합니다.

  ```powershell
  winget install equalsraf.win32yank
  ```

### Neovim 버전이 0.11 미만

이 설정은 Neovim 0.11 이상이 필요합니다. `nvim --version`으로 확인하세요.
설치 스크립트를 다시 실행하면 낮은 버전을 올립니다(macOS: brew, Linux: 공식 tarball, Windows: winget).

### Debian 12에서 `openjdk-21-jdk`를 찾을 수 없음

Debian 12(bookworm) 저장소에는 `openjdk-21-jdk`가 없습니다. `java` 항목 설치가 실패하면 JDK 21을 직접 설치하세요.
예를 들어 [Eclipse Temurin](https://adoptium.net/temurin/releases/?version=21)을 받아 설치합니다.

### Go 도구(`gopls` 등) 설치가 실패함 (Debian/Ubuntu)

Mason은 `gopls` 같은 Go 도구를 `go install ...@latest`로 빌드합니다. apt의 `golang-go`는 배포판에 따라 너무 오래되어 최신 도구가 요구하는 Go 버전을 맞추지 못할 수 있습니다.
`go version`으로 확인하고, 낮으면 공식 다운로드 페이지([https://go.dev/dl/](https://go.dev/dl/))에서 최신 Go를 받아 설치한 뒤 다시 시도하세요.

### `rust` 설치 후 `cargo`나 rust_analyzer를 찾지 못함

rustup은 `~/.cargo/bin`을 셸 설정에 추가하지만, 이미 열려 있는 셸에는 반영되지 않습니다.
새 셸(터미널 창)을 열거나 현재 셸에서 다음을 실행한 뒤 Neovim을 다시 시작하세요. Neovim은 `cargo`가 PATH에 있을 때만 rust_analyzer를 설치·설정합니다.

```shell
source "$HOME/.cargo/env"
```

Windows는 새 PowerShell 창을 여세요.

### Windows에서 nvim-spectre 치환이 제한됨

nvim-spectre의 치환은 GNU `sed`를 씁니다. Windows 네이티브에는 없으므로 검색은 되지만 치환 기능이 제한됩니다.

### nvim-treesitter가 `master` 브랜치에 고정된 이유

`lua/plugins.lua`는 nvim-treesitter와 nvim-treesitter-textobjects를 일부러 `branch = "master"`로 고정합니다.
upstream의 기본 브랜치인 `main`은 설정 API가 완전히 바뀌었고, Neovim 0.12 이상과 `tree-sitter` CLI 0.26.1 이상(패키지 관리자로 설치)을 요구합니다. 그대로 두면 Neovim 0.11 환경에서 설치가 깨집니다.
`master`는 더 이상 기능이 추가되지 않는 동결 브랜치입니다. 지금 설정이 실제로 깨질 때(예: 새 Neovim 버전에서 오류) `main` API로 옮길 예정입니다.

## 백업 복구 방법

설치 스크립트가 기존 설정을 백업한 경우, 원래대로 되돌릴 수 있습니다.
백업은 `<대상>.bak.<YYYYMMDD-HHMMSS>` 이름으로 남아 있습니다.

### macOS, Linux, WSL

```shell
# 링크를 지우고 백업 이름을 되돌립니다 (타임스탬프는 실제 값으로 바꾸세요)
rm ~/.config/nvim
mv ~/.config/nvim.bak.20260101-120000 ~/.config/nvim
```

`~/.tmux.conf`, `~/.wezterm.lua`도 같은 방법입니다.

### Windows

정션은 반드시 `cmd /c rmdir`(`/s` 없이)로 지우세요. 정션(링크)만 제거되고 레포 내용은 그대로 남습니다.
**`Remove-Item`은 쓰지 마세요.** Windows PowerShell 5.1에서는 정션 안의 파일, 즉 레포 내용까지 지울 수 있습니다.

```powershell
# 정션을 지우고 백업 이름을 되돌립니다 (타임스탬프는 실제 값으로 바꾸세요)
cmd /c rmdir "$env:LOCALAPPDATA\nvim"
Rename-Item $env:LOCALAPPDATA\nvim.bak.20260101-120000 nvim

# WezTerm 설정 환경변수를 삭제합니다
[Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE', $null, 'User')
```

환경변수 삭제는 새로 여는 터미널부터 적용됩니다.
