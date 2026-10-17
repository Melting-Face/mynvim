# 크로스 플랫폼 설치 및 README 정비 설계

- 작성일: 2026-10-17
- 대상 레포: `github.com/Melting-Face/mynvim`

## 1. 의도와 이유

현재 neovim 구성은 macOS(brew) 전용이다. 이를 **Linux, Windows 네이티브, WSL**에서도 같은 경험으로 쓰고,
**다른 사람도 README만 보고 따라 설치**할 수 있게 만든다.

현재 문제 (레포 확인 결과):
- `nvim.sh`는 brew 전용이며, tmux/go/rust를 무조건 설치한다. README의 `sh nvim.sh all` 인자는 실제로 처리되지 않는다.
- `init.lua`는 하드링크(`ln -f`), `lua/`·`ftplugin/`은 심볼릭 링크로 연결 방식이 섞여 있다.
- 기존 `~/.config/nvim`이 있으면 백업 없이 덮어쓴다. 재실행 안전성(멱등성)이 없다.
- 설정 코드에 Unix 전용 가정이 있다:
  - `lua/configs/options.lua:4` `vim.o.shell = 'zsh'` 고정
  - `lua/configs/options.lua:28` `os.getenv("HOME")` 기반 undodir
  - `lua/plugins.lua:473-474` mason 경로를 `HOME/.local/share/nvim/mason`으로 하드코딩 (codelldb)
  - `lua/plugins.lua:625-627` `io.popen("which python3")`, `pip list | grep debugpy`
  - `ftplugin/java.lua:1-2` mason 경로 하드코딩 (jdtls)
  - `tmux.conf` `default-command "/bin/zsh"` 고정
- README는 tmux 플러그인 목록·팁 위주이며, 사전 요구사항/OS별 설치/nvim 플러그인 설명이 없다.
- `vim.md`(Vundle)는 현재 구성과 무관하다.

## 2. 목표 / 비목표 / 반목표

**목표**
1. macOS, Linux(Ubuntu/Debian 우선, Fedora·Arch는 가능한 범위), Windows 네이티브, WSL에서 설치 스크립트 한 번으로 동작하는 nvim 환경.
2. 필수 구성요소만 기본 설치, 선택 구성요소는 사용자가 고를 때만 설치.
3. 재실행해도 안전(이미 설치된 것은 건너뜀, 기존 설정은 백업).
4. 한국어 README 하나로 처음 보는 사람이 OS별로 따라 설치 가능.
5. 기준 터미널은 WezTerm이며, README에서 이를 명시하고 OS별 설치를 안내.

**비목표**
- Windows 네이티브에서 tmux 대체재(WezTerm 멀티플렉서 등) 제공.
- 제거(uninstall) 스크립트 — README에 수동 복구 방법만 안내.
- 플러그인 구성 자체의 기능 변경(키맵·플러그인 추가/삭제).
- 영어 README.

**반목표 (동작해도 실패로 간주)**
- 사용자의 기존 nvim 설정이 백업 없이 사라짐.
- 선택하지 않은 도구(tmux, rust 등)가 설치됨.
- macOS에서 기존에 잘 되던 동작이 깨짐.
- 관리자 PowerShell로 실행해야만 하는 Windows 설치 흐름. (winget 설치 중 UAC 확인 창이 뜨는 것은 허용)

## 3. 사용자가 결정한 사항

| 항목 | 결정 |
|---|---|
| 대상 환경 | macOS + Linux(apt 우선, dnf·pacman 가능 범위) + Windows 네이티브 + WSL |
| 필수 구성요소 | neovim ≥ 0.11, git, ripgrep, node, python, C 컴파일러 |
| 선택 구성요소 | tmux(+tpm), go, rust, java, lua |
| 선택 방식 | 플래그(`--with tmux,rust` 등)와 대화형 모두 지원. 인자 없이 실행하면 대화형 |
| 기존 설정 | 자동 백업(`nvim.bak.<YYYYMMDD-HHMMSS>`) 후 연결, 이미 이 레포로 연결되어 있으면 건너뜀 |
| 레거시 문서 | `vim.md` 삭제, `tmuxinator.md`는 `docs/`로 이동 |
| README | 한국어 단일 문서 |
| 설정 코드 | OS 독립적으로 수정 (`stdpath()`, `exepath()` 등) |
| Windows 권한 | UAC 확인 창은 허용, 관리자 셸 실행은 요구하지 않음 |
| Windows C 컴파일러 | zig (winget 사용자 범위 설치, nvim-treesitter 지원 컴파일러) |
| LSP 자동 설치 | 언어 도구가 PATH에 있을 때만 해당 LSP 포함: jdtls·gradle_ls는 `java`, rust_analyzer는 `cargo` |
| 기준 터미널 | WezTerm. README에 "WezTerm 기준으로 검증, 다른 터미널은 동작할 수 있으나 보장하지 않음" 명시 |
| WezTerm 설치 | README 안내만 함. 설치 스크립트는 WezTerm을 설치하지 않음 |
| WezTerm 설정 | 레포에 최소한의 `wezterm.lua` 포함 (테마 색상, Windows 기본 셸 pwsh, WSL 기본 도메인) |

## 4. 설계

### 4.1 파일 구성

| 파일 | 역할 |
|---|---|
| `install.sh` (신규) | macOS / Linux / WSL 설치 (bash) |
| `install.ps1` (신규) | Windows 네이티브 설치 (PowerShell 5.1 이상 호환) |
| `nvim.sh` (삭제) | `install.sh`로 대체 |
| `README.md` (재작성) | 한국어 설치·사용 가이드 |
| `.gitignore` (신규) | `lazy-lock.json` 제외 |
| `wezterm.lua` (신규) | WezTerm 최소 설정 (OS별 분기: Windows는 pwsh 기본 + WSL 도메인 사용 가능) |
| `docs/tmux.md` (신규) | tmux·tpm·tmuxinator 사용법 (`tmuxinator.md` 흡수) |
| `vim.md`, `tmuxinator.md` (삭제) | |
| `lua/configs/options.lua`, `lua/plugins.lua`, `ftplugin/java.lua`, `tmux.conf` (수정) | OS 독립화 |

### 4.2 설치 스크립트 인터페이스

```
./install.sh [--with <comma-list>] [--all] [--yes] [--dry-run] [--help]
.\install.ps1 [-With <comma-list>] [-All] [-Yes] [-DryRun]
```
- 선택 항목 이름: `tmux`, `go`, `rust`, `java`, `lua`
- `--all`: 모든 선택 항목 설치 (Windows에서는 tmux 제외)
- `--yes`: 대화형 질문 없이 진행 (선택 항목 미지정 시 필수만 설치)
- `--dry-run`: 실행할 명령만 출력하고 아무것도 변경하지 않음 (테스트용)
- 인자 없이 실행 + TTY인 경우: 선택 항목마다 y/N 질문
- 알 수 없는 항목 이름은 에러로 종료 (exit 2)

### 4.3 OS 감지와 패키지 관리자

| 환경 | 감지 | 패키지 관리자 |
|---|---|---|
| macOS | `uname -s` = Darwin | brew (없으면 설치 안내 후 종료) |
| Linux | `/etc/os-release`의 ID / ID_LIKE | apt → dnf → pacman 순 |
| WSL | `/proc/version`에 `microsoft` 포함 | Linux와 동일 + 클립보드 처리 |
| Windows | `install.ps1` | winget |

**neovim 버전 처리**: apt 등 배포판 저장소의 nvim은 0.11 미만일 수 있으므로, Linux에서는 설치된 nvim이 0.11 미만이거나 없으면
GitHub 공식 릴리스 tarball을 `~/.local/opt/nvim`에 풀고 `~/.local/bin/nvim`으로 링크한다 (sudo 불필요).

**클립보드** (`clipboard=unnamedplus` 사용 중): Linux는 `wl-clipboard`(Wayland) 또는 `xclip`(X11)을 필수로 설치,
WSL은 Windows 측 `win32yank.exe`가 PATH에 없으면 안내 메시지 출력.

### 4.4 설정 연결 방식

- 레포 전체를 nvim 설정 디렉터리로 연결한다 (기존의 파일별 링크 대신).
  - Unix: `${XDG_CONFIG_HOME:-$HOME/.config}/nvim` → 레포 경로 심볼릭 링크
  - Windows: `%LOCALAPPDATA%\nvim` → 레포 경로 **디렉터리 정션** (관리자 권한/개발자 모드 불필요)
- 대상이 이미 이 레포를 가리키면 건너뜀. 다른 내용이면 백업 후 연결.
- tmux 선택 시: `~/.tmux.conf` → 레포 `tmux.conf` 심볼릭 링크(기존 파일 백업), tpm 미설치 시 clone.
- WezTerm이 PATH에서 감지되면 `~/.wezterm.lua`(Windows: `%USERPROFILE%\.wezterm.lua`)를 레포 `wezterm.lua`로 연결한다(기존 파일은 백업). Windows는 파일 심볼릭 링크에 개발자 모드가 필요하므로, 링크 대신 사용자 범위 환경변수 `WEZTERM_CONFIG_FILE`을 레포의 `wezterm.lua` 경로로 설정한다(관리자 권한 불필요). 감지되지 않으면 건너뛰고 안내만 출력한다. WSL 안에서 실행한 `install.sh`는 이 단계를 건너뛴다(WezTerm 설정은 Windows 쪽에 있음).
- 마지막에 `nvim --headless "+Lazy! sync" +qa` 실행.

### 4.5 설정 코드 OS 독립화

| 위치 | 변경 |
|---|---|
| `options.lua` shell | Windows면 `pwsh`(없으면 `powershell`) 및 관련 shell 옵션, 그 외 `zsh`가 실행 가능하면 `zsh`, 아니면 기본값 유지 |
| `options.lua` undodir | `vim.fn.stdpath("state") .. "/undo"` 및 디렉터리 생성 |
| `plugins.lua` codelldb | `vim.fn.stdpath("data") .. "/mason/packages/codelldb/..."`, Windows는 `.exe` |
| `plugins.lua` dap-python | `vim.fn.exepath("python3")` → 없으면 `exepath("python")`, debugpy 확인은 `python -c "import debugpy"` 종료 코드로 |
| `ftplugin/java.lua` | mason 경로 `stdpath("data")` 기반, Windows는 `jdtls.cmd` 등 확장자 처리 |
| `tmux.conf` | `default-command`를 `$SHELL` 기반으로 |
| `plugins.lua` language_servers | 조건부 목록: `vim.fn.executable("java") == 1`일 때 jdtls·gradle_ls, `executable("cargo") == 1`일 때 rust_analyzer 추가 |
| `plugins.lua` treesitter | Windows에서 zig를 컴파일러로 사용하도록 `require("nvim-treesitter.install").compilers` 지정 |

### 4.6 README 구성 (한국어)

1. 소개 (한 문단 + 지원 OS 표). **이 구성은 WezTerm 터미널 환경을 기준으로 한다**고 명시
2. 터미널 준비: WezTerm 설치 안내 (OS별: macOS `brew install --cask wezterm`, Windows `winget install wez.wezterm`,
   Linux는 공식 설치 문서 링크). WezTerm은 JetBrains Mono와 Nerd Font 심볼을 내장하므로 별도 폰트 설치가 필요 없다는 점,
   WSL 사용자는 Windows 측 WezTerm에서 WSL 도메인으로 접속하는 방법 안내
3. 빠른 시작 — OS별 3줄 이내 명령 (macOS / Linux·WSL / Windows)
4. 설치 옵션 표 (플래그, 선택 항목별 설치 내용)
5. 설치되는 것 (필수/선택, OS별 패키지 이름)
6. 주요 키맵 및 팁 (기존 TIP 내용 정리, leader = `,`)
7. 플러그인 목록 (nvim / tmux)
8. 문제 해결 (실행 정책, PATH, 클립보드, nvim 버전)
9. 백업 복구 방법

### 4.7 검증 방법

- 정적 검사: `shellcheck install.sh`, `Invoke-ScriptAnalyzer install.ps1`
- 단위 수준: 각 스크립트의 `--dry-run` 출력을 OS·옵션 조합별로 확인
- 통합: GitHub Actions 매트릭스(ubuntu-latest, macos-latest, windows-latest)에서 설치 후
  `nvim --headless "+Lazy! sync" +qa`와 `nvim --headless "+lua assert(vim.fn.has('nvim-0.11')==1)" +qa` 성공 확인.
  mason의 LSP/도구 설치 완료는 비동기·네트워크 의존이라 CI 성공 기준에서 제외
- Linux 배포판(Fedora, Arch)은 Docker 컨테이너에서 `install.sh --yes` 수동 확인

## 5. 내가 판단한 사항 (Claude의 결정)

- 스크립트 이름을 `install.sh` / `install.ps1`로 변경하고 `nvim.sh`는 삭제.
- 레포 전체를 설정 디렉터리로 연결 (새 파일 추가 시 링크 누락 방지). 이에 따라 `lazy-lock.json`이 레포 안에 생기는데, **커밋하지 않고 `.gitignore`에 추가**한다(사용자 결정).
- `.claude/`, `.agents/`, `skills-lock.json`은 nvim 동작에 영향이 없으므로 그대로 둔다.
- Windows 패키지 관리자는 OS 기본 제공인 winget.
- macOS에서 brew가 없으면 자동 설치하지 않고 안내 후 종료(외부 스크립트 실행 위험 회피).
- rust는 rustup을 `-y`로 비대화형 설치(사용자가 선택했을 때만).
- java 선택 시 JDK 21(Temurin) 설치 — jdtls는 JDK 17 이상 필요.
- GitHub Actions CI 추가.
- `wezterm.lua` 연결은 WezTerm이 감지될 때만 자동으로 한다. WezTerm 설치 자체는 하지 않는다는 결정을 지키면서도 따라 하기 쉽게 하기 위함이다.
- 레포 받기: 원격 스크립트 한 줄 실행(`curl | bash`) 방식은 쓰지 않는다. `git clone`으로 원하는 위치(README 예시는 `~/mynvim`)에 받은 뒤 스크립트를 실행한다. clone한 경로가 곧 설정 경로가 된다는 점을 README에 명시하고, 레포를 설정 디렉터리에 직접 clone한 경우(원본과 대상이 같음)는 연결 단계를 건너뛴다.
- 선택 항목 `lua`는 Lua 5.4 인터프리터만 설치한다(기존 `brew install lua`와 같음). 이 구성은 luarocks를 쓰지 않는다.
- macOS에서는 `gnu-sed`를 필수로 계속 설치한다. nvim-spectre(`lua/plugins.lua:87`)가 macOS 기본 BSD sed와 호환되지 않기 때문이다. Linux는 기본 sed가 GNU sed라 필요 없고, Windows에서는 spectre 치환 기능이 제한될 수 있다고 README에 적는다.

## 6. 빌더에게 맡기는 사항

- 스크립트 내부 함수 분리 방식, 출력 메시지 문구와 색상.
- 배포판별 정확한 패키지 이름 매핑(예: `ripgrep`, `build-essential` / `gcc`, `python3-pip`).
- Node 버전이 너무 낮은 배포판에서의 처리 방식(최소 18 이상 보장만 지키면 됨).
- README 문장 표현과 세부 예시.
