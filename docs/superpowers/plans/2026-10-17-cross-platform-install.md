# 크로스 플랫폼 설치 및 README 정비 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 이 nvim 구성을 macOS·Linux·WSL·Windows 네이티브에서 스크립트 한 번으로 설치하고, 한국어 README만 보고 따라 할 수 있게 만든다.

**Architecture:** 설정 코드의 Unix 전용 가정을 작은 헬퍼 모듈(`configs.paths`, `configs.lsp_servers`)로 걷어낸다. 설치는 `install.sh`(bash 3.2 호환)와 `install.ps1`(PowerShell 5.1 호환)로 나누고, 둘 다 `--dry-run`과 환경변수 오버라이드로 테스트할 수 있게 sourcing 가능한 함수 구조로 만든다. 레포 전체를 nvim 설정 디렉터리로 연결한다.

**Tech Stack:** Neovim ≥ 0.11 (Lua), bash 3.2+, PowerShell 5.1+/Pester 5, shellcheck, PSScriptAnalyzer, GitHub Actions, WezTerm.

**Spec:** `docs/superpowers/specs/2026-10-17-cross-platform-install-design.md`

## Global Constraints

- neovim 최소 버전 0.11 (`vim.fn.has('nvim-0.11') == 1`).
- `install.sh`는 macOS 기본 bash 3.2에서 동작해야 한다: 연관 배열, `mapfile`, `${var,,}` 금지. shebang `#!/usr/bin/env bash`.
- `install.ps1`은 Windows PowerShell 5.1에서 동작해야 한다 (`??`, 삼항 연산자 금지).
- 선택 항목 이름은 정확히 `tmux`, `go`, `rust`, `java`, `lua`. 알 수 없는 이름 → exit 2.
- 선택하지 않은 도구는 절대 설치하지 않는다. Windows는 `tmux`를 지원하지 않는다(`-All`에서 제외, 명시 지정 시 경고 후 건너뜀).
- 기존 대상은 `<대상>.bak.<YYYYMMDD-HHMMSS>`로 백업한 뒤 연결한다. 대상이 이미 레포를 가리키면 아무것도 하지 않는다.
- 관리자 셸 실행을 요구하지 않는다(winget의 UAC 창은 허용). Windows C 컴파일러는 zig.
- Lua 들여쓰기는 기존 코드처럼 2칸, 새 bash/PowerShell 파일은 4칸. 주석은 한국어.
- README는 한국어 단일 문서. 기준 터미널은 WezTerm이고 "WezTerm 기준 검증, 다른 터미널은 보장하지 않음"을 명시한다.
- `lazy-lock.json`은 `.gitignore`에 넣는다.
- 커밋은 Conventional Commits 형식에 한국어 설명을 쓰고, 끝에 `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`을 붙인다.

## Review Focus

1. **공백이 들어간 경로** (`C:\Users\John Doe\...`, `~/my repos/mynvim`): 모든 링크·백업·환경변수 단계가 정상 동작해야 한다 → Task 4, Task 5 테스트
2. **재실행** (이미 연결됨 / 이전 실행이 중간에 실패): 이미 연결된 대상은 백업을 새로 만들지 않고 건너뛰어야 한다 → Task 4, Task 5 테스트
3. **TTY 없이 인자 없이 실행** (CI, 파이프): 질문하지 않고 필수 항목만 설치해야 한다 → Task 2 테스트
4. **대상이 다른 곳을 가리키는 심볼릭 링크이거나 깨진 링크**: 링크 자체를 백업해야 하고, 링크가 가리키는 내용은 건드리지 않아야 한다 → Task 4 테스트
5. **WSL에서 Windows PATH로 `wezterm.exe`가 보이는 경우**: WSL의 `install.sh`는 WezTerm 설정 연결을 건너뛰어야 한다 → Task 4 테스트

---

## File Structure

| 파일 | 책임 |
|---|---|
| `lua/configs/paths.lua` (신규) | OS 판별, mason 패키지 경로, 실행 파일 확장자 |
| `lua/configs/lsp_servers.lua` (신규) | 조건부 LSP 목록 |
| `lua/configs/options.lua`, `lua/plugins.lua`, `ftplugin/java.lua`, `tmux.conf` (수정) | 헬퍼 사용, OS 분기 |
| `tests/lua/*_spec.lua`, `tests/run_lua.sh` (신규) | headless nvim 기반 Lua 테스트 |
| `install.sh`, `tests/install_sh_test.sh` (신규) | Unix 설치기와 테스트 |
| `install.ps1`, `tests/install.Tests.ps1` (신규) | Windows 설치기와 Pester 테스트 |
| `wezterm.lua` (신규) | WezTerm 최소 설정 |
| `README.md`, `docs/tmux.md`, `.gitignore` (재작성/신규) | 문서 |
| `.github/workflows/ci.yml` (신규) | 3개 OS 매트릭스 검증 |
| `nvim.sh`, `vim.md`, `tmuxinator.md` (삭제) | |

---

### Task 1: 설정 코드 OS 독립화

**Files:**
- Create: `lua/configs/paths.lua`, `lua/configs/lsp_servers.lua`, `tests/lua/paths_spec.lua`, `tests/lua/lsp_servers_spec.lua`, `tests/lua/options_spec.lua`, `tests/run_lua.sh`
- Modify: `lua/configs/options.lua:4,28`, `lua/plugins.lua:1-19` (language_servers), `:204-212` (treesitter), `:473-479` (codelldb), `:625-631` (dap-python), `:677` (ensure_installed), `ftplugin/java.lua:1-15`, `tmux.conf:6`

**Interfaces:**
- Produces:
  - `require("configs.paths").is_windows() -> boolean`
  - `require("configs.paths").mason_package(name: string) -> string`: `stdpath("data") .. "/mason/packages/" .. name`
  - `require("configs.paths").exe(path: string) -> string`: Windows면 `path .. ".exe"`, 아니면 그대로
  - `require("configs.lsp_servers").list(executable?: fun(name:string):boolean) -> string[]`: 기본 predicate는 `function(n) return vim.fn.executable(n) == 1 end`
  - `tests/run_lua.sh`: `tests/lua/*_spec.lua`를 각각 `nvim --headless -u NONE -l <file>`로 실행하고, 하나라도 실패하면 exit 1

- [ ] **Step 1: 실패하는 테스트 작성**

각 spec 파일 맨 위에 `vim.opt.rtp:prepend(vim.fn.getcwd())`를 넣고, 실패하면 `error()`, 끝까지 가면 `os.exit(0)`.

```lua
-- tests/lua/lsp_servers_spec.lua
local servers = require("configs.lsp_servers")
local none = servers.list(function() return false end)
assert(not vim.tbl_contains(none, "jdtls"))
assert(not vim.tbl_contains(none, "gradle_ls"))
assert(not vim.tbl_contains(none, "rust_analyzer"))
assert(vim.tbl_contains(none, "lua_ls") and vim.tbl_contains(none, "pyright"))
local all = servers.list(function() return true end)
assert(vim.tbl_contains(all, "jdtls") and vim.tbl_contains(all, "gradle_ls") and vim.tbl_contains(all, "rust_analyzer"))
local java_only = servers.list(function(n) return n == "java" end)
assert(vim.tbl_contains(java_only, "jdtls") and not vim.tbl_contains(java_only, "rust_analyzer"))
```

```lua
-- tests/lua/paths_spec.lua
local paths = require("configs.paths")
assert(paths.mason_package("jdtls") == vim.fn.stdpath("data") .. "/mason/packages/jdtls")
assert(paths.is_windows() == (vim.fn.has("win32") == 1))
if paths.is_windows() then assert(paths.exe("a/codelldb") == "a/codelldb.exe")
else assert(paths.exe("a/codelldb") == "a/codelldb") end
```

```lua
-- tests/lua/options_spec.lua
require("configs.options")
assert(vim.o.undodir:find(vim.fn.stdpath("state") .. "/undo", 1, true) == 1)
assert(vim.fn.isdirectory(vim.fn.stdpath("state") .. "/undo") == 1)
if vim.fn.has("win32") == 1 then assert(vim.o.shell:match("pwsh") or vim.o.shell:match("powershell"))
elseif vim.fn.executable("zsh") == 1 then assert(vim.o.shell == "zsh") end
```

`tests/lua/no_home_spec.lua`에서는 `lua/`와 `ftplugin/` 아래 모든 파일을 읽어 `os.getenv("HOME")`, `which python3`, `| grep`가 나오지 않는지 확인한다.

- [ ] **Step 2: 실패 확인**

Run: `bash tests/run_lua.sh`
Expected: FAIL (`module 'configs.lsp_servers' not found` 등)

- [ ] **Step 3: 구현**

  - `paths.lua`와 `lsp_servers.lua`를 만든다. `lsp_servers.list`는 기존 목록에서 jdtls·gradle_ls(`java` 있을 때)와 rust_analyzer(`cargo` 있을 때)만 조건부로 넣고, 나머지는 기존 순서를 유지한다.
  - `plugins.lua`: `language_servers` 상수를 `require("configs.lsp_servers").list()`로 바꾼다.
    - 같은 목록을 쓰는 곳(`ensure_installed`, LSP setup 루프)이 모두 이 결과를 쓰게 한다.
    - codelldb는 `paths.exe(paths.mason_package("codelldb") .. "/codelldb")`로 바꾼다.
    - dap-python은 `vim.fn.exepath("python3")`가 비어 있으면 `exepath("python")`을 쓴다. debugpy 확인은 `vim.system({py, "-c", "import debugpy"}):wait().code == 0`으로 한다.
    - treesitter config 함수 첫 줄에서 Windows면 `require("nvim-treesitter.install").compilers = { "zig", "gcc", "clang" }`을 지정한다.
  - `options.lua`의 shell 설정
    - Windows: `pwsh`(실행 가능하면, 아니면 `powershell`)으로 지정하고 `:help shell-powershell`의 `shellcmdflag`, `shellredir`, `shellpipe`, `shellquote`, `shellxquote` 값을 함께 설정한다.
    - 그 외: `zsh`가 실행 가능할 때만 `zsh`로 지정한다.
  - `options.lua`의 undodir: `stdpath("state") .. "/undo"`로 바꾸고 `vim.fn.mkdir(dir, "p")`로 디렉터리를 만든다.
  - `ftplugin/java.lua`: `paths.mason_package(...)`를 쓴다. Windows에서는 `jdtls` 실행 파일 이름을 `jdtls.cmd`로 한다.
  - `tmux.conf`: `set -g default-command "${SHELL}"`로 바꾼다.

- [ ] **Step 4: 통과 확인**

Run: `bash tests/run_lua.sh && nvim --headless "+Lazy! sync" +qa && nvim --headless +qa 2>&1 | grep -i error`
Expected: spec 전부 PASS, 마지막 grep 출력 없음

- [ ] **Step 5: 커밋**

```bash
git add lua ftplugin tmux.conf tests/lua tests/run_lua.sh
git commit -m "refactor(config): 경로와 셸 설정을 OS 독립적으로 변경"
```

---

### Task 2: install.sh 뼈대 (인자, 플랫폼 감지, dry-run)

**Files:**
- Create: `install.sh`, `tests/install_sh_test.sh`

**Interfaces:**
- Produces (모두 `install.sh`를 `source`하면 사용 가능. `main`은 `[[ "${BASH_SOURCE[0]}" == "$0" ]]`일 때만 실행):
  - 전역 변수: `WITH`(공백 구분 문자열), `ASSUME_YES`(0/1), `DRY_RUN`(0/1), `PLATFORM`(`macos|linux|wsl`), `PKG`(`brew|apt|dnf|pacman`), `REPO_DIR`(스크립트 위치의 절대 경로)
  - `parse_args "$@"`: `--with a,b`, `--all`, `--yes`, `--dry-run`, `--help`를 처리. 알 수 없는 항목·플래그는 stderr 메시지와 함께 `exit 2`
  - `detect_platform`: `MYNVIM_PLATFORM`, `MYNVIM_PKG` 환경변수가 있으면 그 값을 우선 사용
  - `choose_components`: `WITH`가 비어 있고 `ASSUME_YES=0`이며 stdin이 TTY(`[ -t 0 ]`)일 때만 항목별로 y/N을 질문
  - `run <cmd...>`: `DRY_RUN=1`이면 `+ <cmd>`를 stdout에 출력, 아니면 실행
- 테스트 하네스: `tests/install_sh_test.sh`는 `assert_contains`, `assert_not_contains`, `assert_exit` 헬퍼를 가진 순수 bash 스크립트(bats 미사용). 실패하면 exit 1

- [ ] **Step 1: 실패하는 테스트 작성**

```bash
# 출력과 종료 코드 단언 (모두 --dry-run, MYNVIM_PLATFORM=linux MYNVIM_PKG=apt)
test_unknown_component_exits_2      # ./install.sh --with foo --dry-run → exit 2
test_all_expands_to_five            # source 후 parse_args --all → WITH == "tmux go rust java lua"
test_with_list_parsed               # parse_args --with tmux,rust → WITH == "tmux rust"
test_non_tty_no_args_core_only      # ./install.sh --dry-run < /dev/null → 출력에 "tmux"/"rustup" 없음, exit 0
test_platform_override              # MYNVIM_PLATFORM=wsl → PLATFORM == wsl
test_detect_wsl_from_proc_version   # MYNVIM_PROC_VERSION="...microsoft..." → PLATFORM == wsl
```

- [ ] **Step 2: 실패 확인** — Run: `bash tests/install_sh_test.sh` / Expected: FAIL (install.sh 없음)
- [ ] **Step 3: 구현.** 위 함수들을 구현한다. `detect_platform` 규칙: Darwin은 macos. `/proc/version`(테스트에서는 `MYNVIM_PROC_VERSION`)에 `microsoft`가 있으면 wsl. 그 외에는 linux. PKG는 `command -v`로 apt-get → dnf → pacman 순으로 찾는다.
- [ ] **Step 4: 통과 확인** — Run: `bash tests/install_sh_test.sh && shellcheck install.sh tests/install_sh_test.sh` / Expected: 모두 PASS, shellcheck 경고 0
- [ ] **Step 5: 커밋** — `git commit -m "feat(install): install.sh 인자 처리와 플랫폼 감지 추가"`

---

### Task 3: install.sh 패키지 설치

**Files:**
- Modify: `install.sh`, `tests/install_sh_test.sh`

**Interfaces:**
- Consumes: Task 2의 `run`, `PKG`, `PLATFORM`, `WITH`
- Produces:
  - `pkg_names <component>`: 현재 `PKG` 기준 패키지 이름을 공백 구분으로 echo. 해당 패키지 관리자에 없는 항목은 빈 문자열
  - `install_core`, `install_optional <name>`, `ensure_nvim`

패키지 매핑 (빌더가 `apt-cache show` 등으로 검증 후 확정):

| component | brew | apt | dnf | pacman |
|---|---|---|---|---|
| core | git ripgrep node python gcc 없음(Xcode CLT 안내) gnu-sed | git ripgrep nodejs npm python3 python3-pip python3-venv build-essential curl unzip + 클립보드 | git ripgrep nodejs python3 python3-pip gcc make curl unzip + 클립보드 | git ripgrep nodejs npm python python-pip base-devel curl unzip + 클립보드 |
| tmux | tmux | tmux | tmux | tmux |
| go | go | golang-go | golang | go |
| rust | (rustup 공식 스크립트 `-y`) | 동일 | 동일 | 동일 |
| java | temurin@21 (cask) | openjdk-21-jdk | java-21-openjdk-devel | jdk21-openjdk |
| lua | lua | lua5.4 | lua | lua |

- 클립보드: linux에서 `WAYLAND_DISPLAY`가 있으면 `wl-clipboard`, 없으면 `xclip`. wsl에서는 설치하지 않고, `win32yank.exe`가 없으면 안내만 출력한다.
- `ensure_nvim`: `nvim`이 없거나 0.11 미만일 때
  - brew 환경: `brew install neovim`
  - 그 외: `https://github.com/neovim/neovim/releases/latest/download/nvim-linux-<x86_64|arm64>.tar.gz`를 `~/.local/opt/nvim`에 풀고 `~/.local/bin/nvim`으로 링크한다. `~/.local/bin`이 PATH에 없으면 안내한다.
- Node 18 미만이면 경고를 출력한다(설치는 하지 않음).
- apt/dnf/pacman 명령은 `sudo`를 붙여 `run`으로 실행한다.

- [ ] **Step 1: 실패하는 테스트 작성**

```bash
test_core_apt_has_build_essential     # MYNVIM_PKG=apt --yes --dry-run → "build-essential" 포함, "tmux" 미포함
test_with_tmux_installs_tmux_and_tpm  # --with tmux → "tmux" 포함, "tmux-plugins/tpm" 포함
test_rust_uses_rustup_noninteractive  # --with rust → "sh.rustup.rs" 와 "-y" 포함
test_brew_core_has_gnu_sed            # MYNVIM_PLATFORM=macos MYNVIM_PKG=brew → "gnu-sed" 포함
test_wsl_skips_clipboard_pkg          # MYNVIM_PLATFORM=wsl → "xclip"/"wl-clipboard" 미포함
test_old_nvim_triggers_tarball        # MYNVIM_NVIM_VERSION=0.9.5 → "nvim-linux-" 포함
test_brew_missing_exits_with_guide    # MYNVIM_PLATFORM=macos, PATH에 brew 없음 → exit 1, "brew.sh" 안내 포함
```
(`MYNVIM_NVIM_VERSION`은 테스트에서 설치된 nvim 버전을 흉내 내는 오버라이드다.)

- [ ] **Step 2: 실패 확인** — Run: `bash tests/install_sh_test.sh` / Expected: 새 테스트 FAIL
- [ ] **Step 3: 구현** — 위 매핑과 규칙대로
- [ ] **Step 4: 통과 확인** — Run: `bash tests/install_sh_test.sh && shellcheck install.sh` / Expected: PASS
- [ ] **Step 5: 커밋** — `git commit -m "feat(install): OS별 필수·선택 패키지 설치 추가"`

---

### Task 4: install.sh 연결·백업·WezTerm·마무리 + wezterm.lua

**Files:**
- Create: `wezterm.lua`
- Modify: `install.sh`, `tests/install_sh_test.sh`

**Interfaces:**
- Consumes: Task 2·3
- Produces:
  - `link_path <src> <dst>`: dst가 src를 가리키는 링크이거나 같은 경로(`cd -P` 기준)면 `already linked`를 출력하고 return 0. dst가 존재하거나 깨진 링크(`[ -e ] || [ -L ]`)면 `mv` 후 `ln -s`. 부모 디렉터리는 `mkdir -p`로 만든다
  - `link_configs`: `${XDG_CONFIG_HOME:-$HOME/.config}/nvim` → `REPO_DIR`. `tmux`를 선택했으면 `~/.tmux.conf` → `REPO_DIR/tmux.conf`. `PLATFORM != wsl`이면서 `command -v wezterm`이 있으면 `~/.wezterm.lua` → `REPO_DIR/wezterm.lua`
  - `main` 끝에서 `run nvim --headless "+Lazy! sync" +qa`를 실행

- [ ] **Step 1: 실패하는 테스트 작성** (dry-run이 아닌 실제 링크 생성. `HOME=$(mktemp -d)`, `XDG_CONFIG_HOME` 미설정. 패키지 단계는 `MYNVIM_SKIP_PACKAGES=1`로 건너뜀)

```bash
test_link_creates_symlink                 # 실행 후 $HOME/.config/nvim -> REPO_DIR
test_existing_dir_backed_up               # 미리 만든 $HOME/.config/nvim/init.lua → nvim.bak.* 아래에 보존
test_rerun_no_new_backup                  # 두 번 실행 → nvim.bak.* 개수 변화 없음
test_dangling_symlink_backed_up           # 깨진 링크를 미리 만들어 둠 → 링크가 백업되고, 원래 링크 대상 경로는 그대로
test_repo_path_with_spaces                # 레포를 "$TMP/my repos/mynvim"에 복사한 뒤 실행 → 링크 정상
test_wsl_skips_wezterm_even_if_on_path    # MYNVIM_PLATFORM=wsl, PATH에 가짜 wezterm → ~/.wezterm.lua 없음
test_clone_into_config_dir_skips     # 레포를 $HOME/.config/nvim 자체에 복사 후 실행 → 백업·링크 없음, "already linked"
test_wezterm_linked_when_present          # MYNVIM_PLATFORM=linux, PATH에 가짜 wezterm → ~/.wezterm.lua -> REPO_DIR/wezterm.lua
```
(`MYNVIM_SKIP_PACKAGES=1`이면 `ensure_nvim`, 설치 단계, `Lazy sync`를 건너뛴다.)

- [ ] **Step 2: 실패 확인** — Run: `bash tests/install_sh_test.sh` / Expected: 새 테스트 FAIL
- [ ] **Step 3: 구현** — `link_path`, `link_configs`를 구현하고 `wezterm.lua`를 작성한다.
  - `wezterm.lua` 내용: `config_builder()`를 쓰고 `color_scheme = "OneDark (base16)"`로 tmux 테마와 맞춘다.
  - Windows(`wezterm.target_triple`에 `windows` 포함)에서는 `default_prog = { "pwsh.exe", "-NoLogo" }`로 설정한다.
  - WSL 사용법은 파일 안 주석으로 안내한다: `default_domain = "WSL:Ubuntu"`.
- [ ] **Step 4: 통과 확인** — Run: `bash tests/install_sh_test.sh && shellcheck install.sh && nvim --headless -u NONE "+lua assert(loadfile('wezterm.lua'))" +qa` / Expected: PASS
- [ ] **Step 5: 커밋** — `git commit -m "feat(install): 설정 연결·백업과 WezTerm 설정 추가"`

---

### Task 5: install.ps1 (Windows 네이티브)

**Files:**
- Create: `install.ps1`, `tests/install.Tests.ps1`

**Interfaces:**
- Produces:
  - `param([string[]]$With, [switch]$All, [switch]$Yes, [switch]$DryRun)`. `-With`는 `tmux,rust`처럼 쉼표 구분과 배열을 모두 받는다
  - `Resolve-Components -With -All -Yes -> string[]`: 알 수 없는 이름은 `exit 2`, `tmux`는 경고 후 제외
  - `Invoke-Step [string]$Command, [scriptblock]$Action`: DryRun이면 `+ $Command`를 출력
  - `Install-WingetPackage -Id <string>`: `winget list --id <Id> -e`로 이미 설치됐는지 확인한 뒤 `winget install --id <Id> -e --accept-source-agreements --accept-package-agreements`
  - `Set-ConfigLink -Source <string> -Target <string>`: `New-Item -ItemType Junction` 사용. 이미 Source를 가리키면 건너뛰고, 아니면 `Rename-Item`으로 백업
  - `Set-WeztermConfig -Path <string>`: `[Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE', $Path, 'User')`. `wezterm`이 감지될 때만 실행
  - 스크립트 끝: `if ($MyInvocation.InvocationName -ne '.') { Main }`
- winget ID (빌더가 `winget show --id`로 검증): core는 `Neovim.Neovim`, `Git.Git`, `BurntSushi.ripgrep.MSVC`, `OpenJS.NodeJS.LTS`, `Python.Python.3.12`, `zig.zig`. 선택 항목은 go `GoLang.Go`, rust `Rustlang.Rustup`, java `EclipseAdoptium.Temurin.21.JDK`, lua `DEVCOM.Lua`
- winget이 없으면 App Installer 설치 안내를 출력하고 exit 1. 설치가 끝나면 현재 세션의 `$env:Path`를 Machine·User 값으로 새로 고친 뒤 `nvim --headless "+Lazy! sync" +qa`를 실행

- [ ] **Step 1: 실패하는 Pester 테스트 작성** (`. ./install.ps1`으로 dot-source해서 함수 단위로 테스트하고, 대상 경로는 `$TestDrive`를 쓴다)

```powershell
It 'unknown component exits 2'
It 'All excludes tmux'                  # Resolve-Components -All → 'go','rust','java','lua'
It 'explicit tmux warns and is dropped'
It 'DryRun prints winget ids'           # -DryRun -With rust → 출력에 'Rustlang.Rustup', 'zig.zig' 포함, 'GoLang.Go' 미포함
It 'junction created'                   # Set-ConfigLink → (Get-Item Target).LinkType -eq 'Junction'
It 'rerun keeps single backup'
It 'path with spaces works'             # Source = "$TestDrive\my repos\mynvim"
```

- [ ] **Step 2: 실패 확인** — Run: `pwsh -c "Invoke-Pester tests/install.Tests.ps1"` (로컬에 pwsh가 없으면 Task 7의 CI에서 확인) / Expected: FAIL
- [ ] **Step 3: 구현**
- [ ] **Step 4: 통과 확인** — Run: `pwsh -c "Invoke-Pester tests/install.Tests.ps1; Invoke-ScriptAnalyzer install.ps1 -Severity Warning,Error"` / Expected: PASS, 분석 결과 0건
- [ ] **Step 5: 커밋** — `git commit -m "feat(install): Windows 네이티브용 install.ps1 추가"`

---

### Task 6: 문서 정비

**Files:**
- Rewrite: `README.md`
- Create: `docs/tmux.md`, `.gitignore`, `tests/docs_test.sh`
- Delete: `nvim.sh`, `vim.md`, `tmuxinator.md`

**Interfaces:**
- Consumes: Task 2~5의 플래그 이름과 동작

- [ ] **Step 1: 실패하는 테스트 작성** — `tests/docs_test.sh`
  - README에 다음 9개 섹션 제목이 순서대로 있다: 소개, 터미널 준비(WezTerm), 빠른 시작, 설치 옵션, 설치되는 것, 주요 키맵, 플러그인 목록, 문제 해결, 백업 복구.
  - README에 `brew install --cask wezterm`, `winget install wez.wezterm`, `WezTerm 기준`, `--with`, `-With`, `ExecutionPolicy`가 들어 있다.
  - README에 `nvim.sh`가 없다.
  - README와 `docs/tmux.md`의 상대 링크가 모두 실제 파일을 가리킨다.
  - `nvim.sh`, `vim.md`, `tmuxinator.md`가 없다.
  - `.gitignore`에 `lazy-lock.json`이 있다.
- [ ] **Step 2: 실패 확인** — Run: `bash tests/docs_test.sh` / Expected: FAIL
- [ ] **Step 3: 작성.** spec 4.6의 9개 섹션 구성을 따른다.
  - 빠른 시작은 OS마다 `git clone` 줄과 실행 줄로 구성한다. Windows 실행 줄은 `powershell -ExecutionPolicy Bypass -File .\install.ps1`이다.
  - "clone한 경로가 곧 설정 경로이므로 옮기지 말 것"을 명시한다.
  - 기존 TIP과 tmux 플러그인 목록은 내용을 그대로 옮긴다. nvim 플러그인 목록은 `lua/plugins.lua`에서 추출해 GitHub 링크 표로 만든다.
  - 백업 복구 절차: 링크를 삭제한 뒤 `*.bak.*`를 원래 이름으로 되돌리고, Windows는 `WEZTERM_CONFIG_FILE`을 삭제한다.
  - `docs/tmux.md`는 tpm 사용법, prefix `C-a`, `tmuxinator.md` 내용을 통합한다.
- [ ] **Step 4: 통과 확인** — Run: `bash tests/docs_test.sh` / Expected: PASS
- [ ] **Step 5: 커밋** — `git commit -m "docs: README를 크로스 플랫폼 설치 가이드로 재작성"`

---

### Task 7: CI

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: 워크플로 작성.** `push`와 `pull_request` 이벤트에서 실행하고, 매트릭스는 `ubuntu-latest`, `macos-latest`, `windows-latest`로 한다.
  - Unix 공통: `shellcheck`, `bash tests/install_sh_test.sh`, `bash tests/docs_test.sh`, `./install.sh --yes`, `bash tests/run_lua.sh`
  - Windows: `Install-Module Pester -MinimumVersion 5 -Force`, `Invoke-Pester`, `Invoke-ScriptAnalyzer`, `.\install.ps1 -Yes`, `nvim --headless -u NONE -l` 로 Lua spec 실행
  - 공통 마무리: `nvim --headless "+lua assert(vim.fn.has('nvim-0.11')==1)" +qa`. mason 설치 완료는 성공 기준에 넣지 않는다.
  - ubuntu 잡에는 `./install.sh --yes --with tmux,go,lua` 단계를 하나 더 둔다.
- [ ] **Step 2: 검증** — Run: `git push`(사용자 승인 후) 뒤 `gh run watch` / Expected: 3개 잡 모두 성공. 실패하면 원인을 해당 Task 파일에서 고치고 다시 push한다.
- [ ] **Step 3: Fedora·Arch 수동 확인** — Run: `docker run --rm -v "$PWD":/r -w /r fedora:latest bash -c 'dnf -y install sudo git && ./install.sh --yes'` (Arch는 `archlinux:latest`, `pacman -Sy --noconfirm sudo git`) / Expected: exit 0 (spec 4.7 "가능한 범위" 확인. 실패하면 README 문제 해결에 기록)
- [ ] **Step 4: 커밋** — `git commit -m "ci: 3개 OS 설치 검증 워크플로 추가"`
