# tmux를 WezTerm 멀티플렉서로 대체 설계

## 의도

tmux는 Windows 네이티브에서 돌지 않아, 지금 이 레포는 OS마다 멀티플렉서가 다르다
(macOS·Linux·WSL은 tmux, Windows는 `wezterm.lua`의 tmux 흉내 키).
사용자가 tmux를 쓰는 이유는 두 가지다.

1. 셸 하나에서 여러 작업을 동시에 하기 (패널·탭)
2. 터미널 앱을 꺼도 작업이 백그라운드에서 유지되기 (detach)

이미 모든 OS의 기준 터미널이 WezTerm이므로, 두 용도를 WezTerm 하나로 해결하고 tmux를 레포에서 뺀다.
특정 OS에 묶이지 않는 하나의 사용법을 갖는 것이 목적이다.

## 목표

- 모든 OS(macOS, Linux, Windows)에서 같은 prefix(`C-a`)와 같은 키로 패널·탭을 쓴다.
- WezTerm을 켜면 항상 로컬 mux 서버(unix domain)에 붙고, 창을 닫거나 `prefix` + `d`로 떼어도
  셸과 실행 중인 작업이 살아 있다. WezTerm을 다시 열면 그대로 이어진다.
- nvim 안에서 `C-h/j/k/l`(창 이동)과 `A-h/j/k/l`(크기 조절)이 지금처럼 nvim 창과 터미널 패널을
  구분 없이 오간다. 지금은 `tmux.nvim`이 tmux 패널에 대해 해 주는 일이다.
- tmux 관련 파일·설치 옵션·CI 검사·문서를 레포에서 없앤다.

## 비목표

- WSL 지원 추가. 사용자는 아직 WSL을 쓰지 않는다. 기존 WSL 관련 동작(`wezterm.lua`의
  `default_domain` 예시 주석, `install.sh`가 WSL에서 WezTerm 설정 연결을 건너뛰는 동작)은 그대로 둔다.
- SSH 원격 서버에서의 세션 유지. 사용자는 로컬 용도만 말했다(원격 서버 tmux 사용은 언급 없음).
- tmux 세션 목록(`prefix` + `s`)·tmuxinator 같은 세션 관리 대체. 필요하면 WezTerm 워크스페이스로 별도 작업한다.
- 재부팅 후 세션 복원. tmux도 하지 않는다.

## 반목표 (기술적으로 돌아가도 실패로 보는 것)

- OS마다 키나 동작이 다시 갈라지는 것.
- 터미널을 열 때마다 네트워크에서 무언가를 받아 와야 하는 구성 (오프라인에서 터미널이 깨짐).
- 이미 설치된 PC의 사용자 파일(`~/.tmux.conf`, `~/.tmux/plugins`)을 설치 스크립트가 지우는 것.
- `--with tmux`를 쓰던 사람이 이유도 모른 채 설치에 실패하는 것.

## 제약

- 로컬 WezTerm 버전: `20240203-110809-5046fc22` (Windows). 이 버전에서 동작해야 한다.
- WezTerm 공식 문서 근거
  - [Multiplexing](https://wezterm.org/multiplexing.html): "Unix domains are supported on all systems, even Windows".
    `unix_domains = { { name = "unix" } }`만으로 "will spawn a server if needed",
    자동 연결은 `default_gui_startup_args = { "connect", "unix" }` 권장
    (`connect_automatically`보다 "works more reliably"). 이 기능은 "still a young feature".
  - [DetachDomain](https://wezterm.org/config/lua/keyassignment/DetachDomain.html): "Detaching does not cause
    those panes to close" (20220624 이후).
- `tmux.nvim`([aserowy/tmux.nvim](https://github.com/aserowy/tmux.nvim))은 tmux만 지원하므로 교체가 필요하다.
- 레포 규칙: Lua는 luacheck·stylua 통과, 셸은 shellcheck, PowerShell은 PSScriptAnalyzer·Pester, 문서 검사는
  `tests/docs_test.sh`. CI(`.github/workflows/ci.yml`)는 lint, ubuntu, macOS, fedora, arch, Windows(pwsh, powershell)에서 돈다.
- TDD: 테스트를 먼저 추가하고 실패를 확인한 뒤 구현한다.

## 결정 사항

### 사용자가 정한 것

- tmux를 레포에서 뺀다. 이유는 특정 OS에 묶이기 때문이다.
- WezTerm은 mux 서버로 시작한다 (항상 unix domain에 연결).
- WSL은 이번 범위에서 다루지 않는다.
- "앱이 꺼져도 백그라운드에서 유지"가 요구 사항이므로, 창의 X 버튼으로 닫아도 작업이 살아 있어야 한다.
  X로 닫았을 때 작업이 죽으면 실패다 (검증 4단계가 합격 기준).

### Claude가 정한 것 (사용자 확인 전 기본값)

- **키:** 지금 `wezterm.lua`의 Windows 분기에 있는 tmux 호환 키 전체(leader `C-a`, 분할, 패널 이동·크기·확대·닫기,
  탭 관리, `prefix` + `0`~`9`, 복사 모드, PREFIX 상태 표시, 50000줄 스크롤백, 0부터 시작하는 탭 번호)를
  모든 OS에 적용한다. Windows 분기에는 기본 셸 `pwsh`만 남긴다.
- **detach 키:** `prefix` + `d` → `DetachDomain` (현재 패널의 도메인). 다시 붙는 방법은 WezTerm을 다시 여는 것이다.
- **nvim 연동:** `tmux.nvim`을 WezTerm 패널과 연동되는 방식으로 바꾸고, 키(`C-h/j/k/l`, `A-h/j/k/l`)는 그대로 둔다.
- **설치 스크립트:**
  - `tmux` 선택 항목, tpm clone, `~/.tmux.conf` 링크를 없앤다.
  - `--with tmux`/`-With tmux`는 실패시키지 않는다. "tmux는 더 이상 설치하지 않습니다 (WezTerm 멀티플렉서 사용, docs 링크)"
    경고를 내고 그 항목만 건너뛴다. 지금 Windows가 tmux를 다루는 방식과 같다.
- **이미 설치된 PC:** 기존 `~/.tmux.conf` 링크와 `~/.tmux/plugins`는 자동으로 지우지 않는다. README에 수동 정리 방법만 안내한다.
- **문서:**
  - `docs/tmux.md`를 `docs/wezterm.md`(WezTerm 멀티플렉서 사용법)로 바꾼다.
  - README와 `docs/keymaps.md`의 tmux 언급, 플러그인 목록, 설치 항목 표를 정리한다.
  - 소개 문구 "Neovim(+ tmux)"를 고친다.
- **우선순위 (연동이 막힐 때):** 사용자의 두 용도(여러 작업, 백그라운드 유지)가 먼저다.
  nvim·WezTerm 패널 연동이 (a)·(b) 모두 unix domain에서 동작하지 않으면 패널을 넘나드는 연동을 포기한다.
  이 경우 `C-h/j/k/l`, `A-h/j/k/l`은 nvim 창 안에서만 동작하고, WezTerm 패널 이동은 `prefix` + `h/j/k/l`을 쓴다.
  mux 시작을 포기하거나 WezTerm을 nightly로 올리지는 않는다. 20240203이 최신 안정 버전이다.
- **상태줄:** tmux 상태줄 위젯(onedark 테마, CPU, 배터리, 날짜)은 옮기지 않는다. WezTerm 오른쪽 상태줄에는
  지금처럼 PREFIX(와 키 테이블) 표시만 둔다. 색상은 기존 `OneDark (base16)` 스킴을 쓴다. 이 사실을 문서에 적는다.
- **지울 것:** `tmux.conf`, tmuxinator 문서, CI의 "tmux 기본 터미널 확인" 단계와 `--with tmux,go,lua`의 tmux.
  tmux 전용 테스트는 지우거나 새 동작(경고 후 건너뜀)에 맞게 바꾼다.

## 빌더에게 맡기는 것

- **nvim·WezTerm 패널 연동 방식.** 후보는 두 가지다.
  - (a) [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) core와
    [backend-wezterm](https://github.com/smart-splits-nvim/backend-wezterm).
    v2부터 백엔드가 분리되었고 `mux.backend`를 명시해야 한다. WezTerm 쪽은 `wezterm.plugin.require(...)`로 설정한다.
    지원하는 WezTerm 최소 버전이 README에 "to be confirmed"로 되어 있다.
  - (b) WezTerm 쪽 키를 `wezterm.lua`에 직접 작성한다. nvim이 알려 주는 user var로 nvim 패널인지 판단해서,
    nvim이면 키를 보내고 아니면 패널을 이동한다.
  - 정하는 기준은 세 가지다: 로컬 WezTerm 20240203에서 unix domain에 붙은 상태로 동작할 것,
    반목표의 "실행 때마다 네트워크 의존"을 피할 것, 유지 비용이 작을 것.
    `wezterm.plugin.require`가 첫 실행 뒤 캐시로 오프라인에서도 동작하는지 확인하고, 안 되면 (b)를 쓴다.
  - 먼저 짧은 스파이크로 확인한다.
- **CI 검증 범위.** 각 OS에서 `wezterm.lua`가 오류 없이 로드되는지 확인할 수 있으면 넣는다
  (예: WezTerm 설치 후 `wezterm --config-file wezterm.lua show-keys`). 설치 비용이 너무 크면 luacheck와 문서 검사로 대신하고, 그 이유를 계획에 적는다.
- 문서 구성과 문구, 테스트 이름과 배치.

## 검증

- 자동
  - 바뀐 설치 동작(`--with tmux` 경고 후 건너뜀, tmux 링크 없음)을 `tests/install_sh_test.sh`, `tests/install.Tests.ps1`에서 검사한다.
  - `tests/docs_test.sh`로 새 문서와 `wezterm.lua` 핵심 설정(unix domain, `default_gui_startup_args`, `prefix` + `d`)을 검사한다.
  - 기존 CI 전체를 통과한다.
- 로컬 Windows 수동 확인 (결과를 PR에 기록한다)
  1. WezTerm을 켜고 패널 분할, 탭 생성, `prefix` + 숫자 이동을 확인한다.
  2. 한 패널에서 오래 도는 작업(예: `ping -t localhost`)을 띄운다.
  3. `prefix` + `d`로 떼어 낸 뒤 WezTerm을 다시 열어 그 작업이 계속 돌고 있는지 확인한다.
  4. 창의 X 버튼으로 닫은 경우도 같은 방법으로 확인한다. 작업이 살아 있어야 합격이다.
     공식 문서에는 X 버튼이 detach인지 종료인지 명확하지 않다. 기본 동작이 종료라면 창 닫기를 detach로 바꾸는 방법을 스파이크로 찾아 구현한다.
     찾은 방법과 결과는 `docs/wezterm.md`에 적는다.
  5. nvim에서 분할한 창과 WezTerm 패널 사이를 `C-h/j/k/l`로 오가고, `A-h/j/k/l`로 크기를 조절한다.
- macOS·Linux 실기기 확인은 Unknown이다. 사용 가능한 기기가 있을 때 같은 절차로 확인한다.

## 위험

- **mux 기능이 아직 "young feature"다.** 특정 OS에서 연결이나 표시가 불안정할 수 있다.
  완화책: `default_gui_startup_args`를 한 줄로 두어 문제가 생기면 그 줄만 끄면 기존 로컬 모드로 돌아가게 하고, 그 방법을 문서에 적는다.
- **nvim 연동 플러그인이 새 버전(v2)이고 WezTerm 버전 호환이 확인되지 않았다.** 빌더 스파이크로 확인하고, 안 되면 (b)로 간다.
- **설정이 서버 쪽에서 적용되지 않을 수 있다.** mux 서버도 같은 `wezterm.lua`를 읽는다.
  설정을 바꾼 뒤에는 서버를 다시 시작해야 적용되는 항목(기본 셸 등)이 있을 수 있으므로 문서에 적는다.
