# tmux를 WezTerm 멀티플렉서로 대체 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** tmux를 레포에서 빼고, 모든 OS에서 WezTerm 하나로 패널·탭과 백그라운드 유지(unix domain mux)를 제공한다.

**Architecture:** `wezterm.lua`의 tmux 호환 키를 Windows 분기 밖으로 옮기고, unix domain에 자동 연결한다.
nvim·WezTerm 패널 연동은 플러그인 없이 직접 작성한다(설계의 (b)안). nvim은 OSC 1337 user var `IS_NVIM`으로 자신을 알리고,
`wezterm.lua`는 그 값을 보고 `C-h/j/k/l`, `A-h/j/k/l`을 nvim에 보낼지 패널을 움직일지 정한다.
nvim 창 끝에서는 `wezterm cli`로 WezTerm 패널을 움직인다.

**Tech Stack:** WezTerm 20240203 Lua 설정, Neovim 0.11 Lua, bash(3.2 호환), PowerShell 5.1/7, Pester, GitHub Actions

**Spec:** `docs/superpowers/specs/2026-10-21-wezterm-replaces-tmux-design.md`

## Global Constraints

- 로컬 WezTerm 버전 `20240203-110809-5046fc22`(Windows)에서 동작해야 한다. nightly로 올리지 않는다.
- 모든 OS에서 같은 prefix(`C-a`)와 같은 키. OS 분기는 Windows의 `default_prog`(pwsh)와 WSL 주석만 남긴다.
- 터미널을 열 때 네트워크가 필요하면 안 된다 (`wezterm.plugin.require` 금지).
- 설치 스크립트는 `~/.tmux.conf`, `~/.tmux/plugins`를 지우지 않는다.
- `--with tmux`/`-With tmux`는 실패하지 않는다. 경고 후 그 항목만 건너뛴다.
- 상태줄은 PREFIX(와 키 테이블) 표시만, 색상은 `OneDark (base16)`.
- Lua: luacheck·stylua(2칸, LF, 120열). 셸: shellcheck, bash 3.2. PowerShell: PSScriptAnalyzer·Pester. 주석은 한국어.
- 커밋 메시지: `type: 한국어 설명` + `Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>`.
- TDD: 테스트를 먼저 쓰고 실패를 확인한 뒤 구현한다.

## 연동 방식 결정 (설계의 "빌더에게 맡기는 것")

(b) `wezterm.lua` 직접 작성을 택한다. 근거는 다음과 같다.

- [smart-splits.nvim README](https://github.com/mrjones2014/smart-splits.nvim): 현재 v3이고 "Core ships no backends", "This is a breaking change". 변경이 잦다.
- [backend-wezterm README](https://github.com/smart-splits-nvim/backend-wezterm): WezTerm 쪽을 `wezterm.plugin.require('https://github.com/...')`로 받는다.
  첫 실행에 네트워크가 필요해 반목표에 걸린다. 최소 WezTerm 버전은 "to be confirmed"다.
- [pane:get_user_vars()](https://wezterm.org/config/lua/pane/get_user_vars.html): 20210502부터 있고, "The user var change event will propagate to all connected multiplexer clients".
- 로컬 `wezterm cli --help`(20240203)에 `activate-pane-direction`, `adjust-pane-size`가 있다(2026-10-21 확인).
- 로컬 확인 결과: 문법 오류가 있는 설정으로 `wezterm --config-file bad.lua show-keys --lua`를 실행해도 종료 코드 0이고 stderr도 비어 있다.
  그래서 CI는 종료 코드가 아니라 출력 내용(`DetachDomain`)으로 로드 성공을 판단한다.

## CI 검증 범위 결정

Windows `pwsh` 레그에서 WezTerm 20240203 Windows zip(설치 없는 portable)을 받아 `show-keys --lua` 출력을 검사한다.
사용자와 같은 OS, 같은 버전이고, 압축 해제만 하므로 비용이 작다. macOS·Linux는 같은 파일을 쓰고 OS 분기가 `default_prog`뿐이므로 luacheck와 문서 검사로 대신한다.

## Review Focus

1. **WezTerm 밖에서 nvim 실행** (Windows Terminal, SSH, `WEZTERM_PANE` 없음): `C-h/j/k/l`, `A-h/j/k/l`은 nvim 창 안에서만 동작하고, `wezterm cli`를 부르거나 OSC를 쓰지 않아야 한다. → Task 3 테스트 `outside wezterm`.
2. **셸 패널에서 `C-l`(화면 지우기)을 빼앗김**: 이동 키가 `C-l`을 가져가므로 `prefix` + `C-l`로 셸에 `C-l`을 보낼 수 있어야 한다. → Task 3 문서·설정 검사.
3. **`--with tmux`만 준 경우(TTY)**: tmux를 빼고 나면 선택 항목이 비는데, 이때 대화형 질문이 다시 뜨면 안 된다(사용자는 `--with`로 이미 답했다). 필수만 설치하고 종료 코드 0. → Task 4 테스트 `test_with_only_tmux_skips_prompt`.
4. **nvim이 일시 중지(`C-z`)되거나 종료됨**: `IS_NVIM`을 지워야 셸로 돌아온 패널에서 `C-h`가 패널 이동으로 동작한다. → Task 3 테스트 `autocmds`.
5. **`wezterm.lua`를 고쳤는데 mux 서버가 예전 설정으로 동작함 / 설정 오류가 조용히 기본값으로 대체됨**: 문서에 서버 재시작 방법이 있어야 하고, CI는 출력 내용으로 로드 성공을 확인한다. → Task 2 CI 단계, Task 5 문서 검사.

---

### Task 1: 로컬 스파이크 (WezTerm 20240203, Windows, 사람 참여)

X 버튼 동작은 [Multiplexing](https://wezterm.org/multiplexing.html), [DetachDomain](https://wezterm.org/config/lua/keyassignment/DetachDomain.html) 어디에도 나오지 않는다. 구현 전에 확인한다.
사용자가 지금 쓰는 WezTerm을 건드리지 않도록 별도 설정과 별도 소켓을 쓴다. 이 작업은 커밋하지 않고, 결과를 이 계획 맨 아래 `## 스파이크 결과`에 적는다.

**Files:**
- Create (scratchpad, 커밋 안 함): `spike.lua` — `unix_domains = { { name = "spike", socket_path = "<scratchpad>/spike.sock" } }`, `default_gui_startup_args = { "connect", "spike" }`, `default_prog = { "pwsh.exe", "-NoLogo" }`

- [ ] **Step 1: mux 연결 확인.** `wezterm --config-file spike.lua connect spike`로 창을 연다. 기대: 창이 뜨고 `wezterm cli --prefer-mux list`(소켓 환경변수 `WEZTERM_UNIX_SOCKET`을 spike.sock으로)에 패널이 보인다. mux 서버 프로세스 이름을 기록한다(예상 `wezterm-mux-server.exe`).
- [ ] **Step 2: X 버튼 확인.** 패널에서 `ping -t localhost`를 띄우고 사용자가 X로 창을 닫는다. 다시 `connect spike`. 기대: ping이 계속 돌고 있다.
  - 살아 있으면 통과.
  - 죽으면 [window events](https://wezterm.org/config/lua/window-events/index.html)와 이슈 트래커에서 창 닫기를 detach로 바꾸는 방법을 찾아 시도한다.
  - 방법이 없으면 **여기서 멈추고 사용자에게 보고한다.** 설계상 합격 기준(검증 4단계)이므로 다른 작업을 진행하지 않는다.
- [ ] **Step 3: user var 전달 확인.** mux 패널의 nvim에서 `:lua vim.api.nvim_chan_send(vim.v.stderr, "\027]1337;SetUserVar=IS_NVIM=" .. vim.base64.encode("true") .. "\007")`를 실행한다. 디버그 오버레이(`Ctrl+Shift+L`)에서 `wezterm.gui.gui_windows()[1]:active_pane():get_user_vars()`를 확인한다. 기대: `IS_NVIM = "true"`.
  - 안 되면 `io.stdout:write(...)`로 다시 시도한다. 둘 다 안 되면 설계의 우선순위 규칙대로 패널 넘나들기 연동을 포기한다. Task 3은 nvim 쪽 창 이동만 남기고 `wezterm.lua`의 스마트 키를 넣지 않는다.
- [ ] **Step 4: `wezterm cli` 포커스 확인.** 패널을 좌우로 나누고 오른쪽 패널에서 `wezterm cli activate-pane-direction Left`, `wezterm cli adjust-pane-size --amount 2 Left`를 실행한다. 기대: GUI 포커스가 왼쪽으로 옮겨지고 크기가 바뀐다.
  - 안 되면 Task 3의 `cli` 대신 user var 신호를 쓴다. nvim이 `WEZTERM_NAV=<move|resize>:<Left|Down|Up|Right>:<증가 숫자>`를 설정하고, `wezterm.lua`의 `wezterm.on("user-var-changed", ...)`가 `ActivatePaneDirection`/`AdjustPaneSize`를 실행한다.
- [ ] **Step 5: 기록.** Step 1~4의 결과, 택한 방법, mux 서버 프로세스 이름을 `## 스파이크 결과`에 적고 사용자에게 한 줄로 보고한다.

### Task 2: `wezterm.lua`를 모든 OS 공통 키 + unix domain 자동 연결로

**Files:**
- Modify: `wezterm.lua` (Windows 분기 안의 leader·키·key_tables·update-status를 분기 밖으로. 분기에는 `default_prog`와 WSL 주석만)
- Modify: `tests/docs_test.sh` (새 테스트 `test_wezterm_lua_mux_config`)
- Modify: `.github/workflows/ci.yml` (windows 잡에 로드 확인 단계)

**Interfaces:**
- Produces: `config.keys`, `config.key_tables`가 모든 OS에 있다. Task 3이 `config.keys`에 항목을 추가한다.

- [ ] **Step 1: 실패하는 테스트 작성.** `tests/docs_test.sh`에 추가:

```bash
test_wezterm_lua_mux_config() {
    local f="$ROOT/wezterm.lua" phrase
    for phrase in 'config.unix_domains = { { name = "unix" } }' \
        'config.default_gui_startup_args = { "connect", "unix" }' \
        'act.DetachDomain("CurrentPaneDomain")'; do
        grep -qF -- "$phrase" "$f" || fail "wezterm.lua에 '$phrase'가 없음"
    done
    # 모든 OS 공통: leader와 키가 OS 분기 안(들여쓰기)에 있으면 안 된다
    grep -qE '^config\.leader = \{ key = "a", mods = "CTRL"' "$f" || fail "leader가 OS 분기 밖에 없음"
    grep -qE '^config\.keys = \{' "$f" || fail "keys가 OS 분기 밖에 없음"
}
```

- [ ] **Step 2: 실패 확인.** Run: `bash tests/docs_test.sh` → Expected: `FAIL test_wezterm_lua_mux_config`
- [ ] **Step 3: 구현.** `wezterm.lua`를 바꾼다.
  - 위 세 줄을 그대로 넣는다. `default_gui_startup_args` 줄 위에 "문제가 생기면 이 줄만 주석 처리하면 예전 로컬 모드로 돌아간다" 주석을 단다.
  - `{ key = "d", mods = "LEADER", action = act.DetachDomain("CurrentPaneDomain") }`을 추가한다.
  - 기존 키(leader, 50000줄, 0부터 시작하는 탭 번호, resize key table, SHIFT 복제 루프, PREFIX 상태줄)는 동작을 바꾸지 않고 들여쓰기만 한 단계 뺀다.
  - 색상 주석 "tmux 테마와 맞춘"을 "OneDark 색상 스킴"으로 고친다.
  - Task 1 Step 2에서 X 버튼 대책이 필요했다면 그 설정도 여기서 넣는다.
- [ ] **Step 4: CI 단계 추가.** `windows` 잡의 PSScriptAnalyzer 다음에 넣는다 (`if: matrix.shell == 'pwsh'`).
  - URL `https://github.com/wezterm/wezterm/releases/download/20240203-110809-5046fc22/WezTerm-windows-20240203-110809-5046fc22.zip`을 `$env:RUNNER_TEMP`에 받아 `Expand-Archive`로 푼다.
  - 그 안의 `wezterm.exe`로 `--config-file wezterm.lua show-keys --lua`를 실행한다.
  - 출력에 `DetachDomain`과 `mods = 'LEADER'`가 없으면 `throw`한다. 주석으로 "설정 오류여도 종료 코드가 0이라 내용으로 판단"을 적는다.
  - 먼저 `curl -sIL <URL> | grep -i '^HTTP'`로 URL이 200에 도달하는지 로컬에서 확인한다.
- [ ] **Step 5: 통과 확인.**
  - `bash tests/docs_test.sh` → 새 테스트 PASS (기존 `test_tmux_doc_windows_wezterm_keys`도 PASS 유지).
  - `luacheck wezterm.lua`, `stylua --check wezterm.lua` → 출력 없음.
  - 로컬 `wezterm --config-file wezterm.lua show-keys --lua | grep -c DetachDomain` → 1 이상.
- [ ] **Step 6: 커밋.** `git commit -m "feat: WezTerm tmux 호환 키를 모든 OS에 적용하고 unix domain에 자동 연결"`

### Task 3: nvim·WezTerm 패널 연동 (`tmux.nvim` 교체)

**Files:**
- Create: `lua/configs/wezterm_nav.lua`
- Create: `tests/lua/wezterm_nav_spec.lua`
- Modify: `init.lua` (`require("configs.keymaps")` 다음 줄에 `require("configs.wezterm_nav").setup()`)
- Modify: `lua/plugins/editor.lua:26-30` (`aserowy/tmux.nvim` 항목 삭제)
- Modify: `tests/lua/dead_refs_spec.lua` (patterns에 `"aserowy/tmux.nvim"` 추가)
- Modify: `wezterm.lua` (스마트 키, `prefix` + `C-l`)
- Modify: `tests/docs_test.sh` (`test_wezterm_lua_mux_config`에 검사 추가)

**Interfaces:**
- Produces (`configs.wezterm_nav`):
  - `M.cli(args: string[])`: `{"wezterm", "cli", ...args}`를 `vim.system`으로 비동기 실행한다. 테스트가 이 필드를 바꿔 끼운다.
  - `M.navigate(dir: "h"|"j"|"k"|"l")`: `wincmd dir`. 창이 그대로이고 `vim.env.WEZTERM_PANE`이 있으면 `M.cli({"activate-pane-direction", <Left|Down|Up|Right>})`.
  - `M.resize(dir: "h"|"j"|"k"|"l")`: 경계를 dir 쪽으로 2칸 옮긴다. 그 축에 이웃 창이 없고 `WEZTERM_PANE`이 있으면 `M.cli({"adjust-pane-size", "--amount", "2", <방향>})`.
    - `h`: 오른쪽 이웃이 있으면 `vertical resize -2`, 왼쪽만 있으면 `+2`.
    - `l`: 오른쪽 이웃이 있으면 `+2`, 왼쪽만 있으면 `-2`.
    - `j`: 아래 이웃이 있으면 `resize +2`, 위만 있으면 `-2`.
    - `k`: 아래 이웃이 있으면 `-2`, 위만 있으면 `+2`.
  - `M.setup()`:
    - `C-h/j/k/l` → `navigate`, `A-h/j/k/l` → `resize` 매핑(n 모드, desc 한국어)을 만든다.
    - `WEZTERM_PANE`이 있을 때만 augroup `WeztermNav`를 만든다. `VimEnter`, `VimResume`에서 `IS_NVIM=true`, `VimLeavePre`, `VimSuspend`에서 `IS_NVIM=` (빈 값).
    - 출력 방식(`nvim_chan_send(vim.v.stderr, ...)` 또는 `io.stdout:write`)은 Task 1 Step 3 결과를 따른다.
- Task 1 Step 4가 실패했다면 `M.cli` 대신 `WEZTERM_NAV` user var를 쓴다(Task 1 참고). 테스트는 `M.cli` 대신 user var를 쓰는 함수를 바꿔 끼운다.

- [ ] **Step 1: 실패하는 테스트 작성.** `tests/lua/wezterm_nav_spec.lua`:

```lua
vim.opt.rtp:prepend(vim.fn.getcwd())
local nav = require("configs.wezterm_nav")
local calls = {}
nav.cli = function(args)
  table.insert(calls, table.concat(args, " "))
end

-- outside wezterm: 창 하나, WEZTERM_PANE 없음 → wezterm cli를 부르지 않는다
vim.env.WEZTERM_PANE = nil
nav.navigate("h")
nav.resize("l")
assert(#calls == 0, "WezTerm 밖에서 cli 호출됨")

-- 창 끝에서 WezTerm 패널로 넘어간다
vim.env.WEZTERM_PANE = "0"
nav.navigate("l")
assert(calls[1] == "activate-pane-direction Right", calls[1])
nav.resize("j")
assert(calls[2] == "adjust-pane-size --amount 2 Down", calls[2])

-- nvim 창이 나뉘어 있으면 nvim 안에서 처리한다
vim.cmd("vsplit")
local before = vim.api.nvim_get_current_win()
nav.navigate("l")
assert(vim.api.nvim_get_current_win() ~= before, "nvim 창 이동 안 됨")
assert(#calls == 2, "nvim 창이 있는데 cli 호출됨")
local width = vim.api.nvim_win_get_width(0)
nav.resize("h")
assert(vim.api.nvim_win_get_width(0) ~= width, "nvim 창 크기 조절 안 됨")
assert(#calls == 2, "nvim 창이 있는데 cli 호출됨")

-- setup: 키 매핑과 autocmds (일시 중지·종료 때 IS_NVIM을 지운다)
nav.setup()
for _, lhs in ipairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>", "<A-h>", "<A-j>", "<A-k>", "<A-l>" }) do
  assert(vim.fn.maparg(lhs, "n") ~= "", lhs .. " 매핑 없음")
end
for _, event in ipairs({ "VimEnter", "VimResume", "VimLeavePre", "VimSuspend" }) do
  assert(#vim.api.nvim_get_autocmds({ group = "WeztermNav", event = event }) == 1, event .. " autocmd 없음")
end
os.exit(0)
```

  `tests/docs_test.sh`의 `test_wezterm_lua_mux_config`에 추가: `IS_NVIM`, `key = "l", mods = "LEADER|CTRL"`이 `wezterm.lua`에 있어야 한다.
- [ ] **Step 2: 실패 확인.** Run: `nvim --headless -u NONE -l tests/lua/wezterm_nav_spec.lua` → Expected: `module 'configs.wezterm_nav' not found`. `bash tests/docs_test.sh` → `FAIL test_wezterm_lua_mux_config`.
- [ ] **Step 3: `lua/configs/wezterm_nav.lua` 구현.** 위 Interfaces대로 만든다. 이웃 창은 `vim.fn.winnr("h") ~= vim.fn.winnr()`로 판단한다. 방향 이름 표는 `{ h = "Left", j = "Down", k = "Up", l = "Right" }`. `init.lua` 연결, `editor.lua`에서 tmux.nvim 삭제, `dead_refs_spec.lua` 패턴 추가.
- [ ] **Step 4: `wezterm.lua` 스마트 키.**
  - `h/j/k/l`마다 `CTRL`(이동)과 `META`(크기) 바인딩을 `wezterm.action_callback`으로 추가한다.
  - `pane:get_user_vars().IS_NVIM == "true"`이면 `act.SendKey({ key = key, mods = mods })`를 보낸다.
  - 아니면 `act.ActivatePaneDirection(dir)` / `act.AdjustPaneSize({ dir, 2 })`.
  - `{ key = "l", mods = "LEADER|CTRL", action = act.SendKey({ key = "l", mods = "CTRL" }) }`(셸 화면 지우기)도 추가한다.
  - SHIFT 복제 루프보다 앞이든 뒤든 상관없다(루프는 `mods == "LEADER"`만 본다).
- [ ] **Step 5: 통과 확인.**
  - `bash tests/run_lua.sh` → 모든 spec PASS (`wezterm_nav_spec`, `dead_refs_spec` 포함).
  - `bash tests/docs_test.sh` → PASS.
  - `nvim --headless tests/fixtures/smoke.c "+luafile tests/startup_smoke.lua"` → 종료 코드 0.
  - `luacheck init.lua lua tests wezterm.lua`, `stylua --check .` → 출력 없음.
- [ ] **Step 6: 커밋.** `git commit -m "feat: tmux.nvim 대신 WezTerm 패널과 nvim 창을 같은 키로 오가는 연동 추가"`

### Task 4: 설치 스크립트에서 tmux 제거 (경고 후 건너뜀)

**Files:**
- Modify: `install.sh` (`ALL_COMPONENTS="go rust java lua"`, usage, `parse_args`, `choose_components`, `pkg_names`, `install_optional`, `link_configs`)
- Modify: `install.ps1` (도움말 `.PARAMETER With/All`, `Get-KnownComponent`, `Get-RequestedComponent`, `Resolve-Components`)
- Modify: `tests/install_sh_test.sh`, `tests/install.Tests.ps1`
- Modify: `.github/workflows/ci.yml` ("설치 (tmux,go,lua 선택)"을 "설치 (go,lua 선택)"과 `--with go,lua`로 바꾸고, "tmux 기본 터미널 확인" 단계 삭제)

**Interfaces:**
- 경고 문구(두 스크립트 동일): `tmux는 더 이상 설치하지 않아 건너뜁니다 (WezTerm 멀티플렉서를 씁니다. docs/wezterm.md 참고)`
- `install.sh`: 새 전역 `WITH_GIVEN=0`. `--with`를 받으면 1이 된다. `choose_components`는 `WITH_GIVEN=1`이면 묻지 않는다.

- [ ] **Step 1: 실패하는 테스트 작성/수정.** `tests/install_sh_test.sh`:
  - `test_all_expands_to_five`를 `test_all_expands_to_four`로 바꾼다. 기대값 `"go rust java lua"`.
  - `test_with_list_parsed`: `--with go,rust` → `"go rust"`.
  - `test_with_and_all_union_dedup`: 기대값 `"go rust java lua"`.
  - `test_main_summary_with_components`: `--with go`로 바꾸고 `golang-go`, `apt`를 확인한다.
  - `test_pacman_first_install_syncs_db`: `--with go`로 바꾸고 `pacman -S --noconfirm --needed go`를 확인한다.
  - `test_choose_components_reads_answers`: 기대값 `"WITH=[go java]"`.
  - `test_with_tmux_installs_tmux_and_tpm`을 `test_with_tmux_warns_and_skips`로 바꾼다.
    - `--with tmux,rust --dry-run 2>&1`이 종료 코드 0이고 출력에 `tmux는 더 이상 설치하지 않아`와 `docs/wezterm.md`가 있다.
    - 출력에 `tmux-plugins/tpm`과 `apt-get install -y tmux`가 없다.
    - `source` 후 `parse_args --with tmux,rust 2>/dev/null` → `WITH == "rust"`.
  - 새 테스트 `test_with_only_tmux_skips_prompt`: `source`, `is_interactive() { return 0; }`, `parse_args --with tmux 2>/dev/null`, `choose_components </dev/null 2>&1` 출력에 `설치할까요`가 없고 `WITH`가 빈 값이다.
  - `test_tmux_conf_linked_only_when_selected`를 `test_tmux_files_never_touched`로 바꾼다.
    - 임시 HOME에 `.tmux.conf`(일반 파일, 내용 `keep`)와 `.tmux/plugins/tpm/x`를 만든다.
    - `run_install "$tmp" "$INSTALL_SH" --with tmux`를 실행한다.
    - 둘 다 그대로이고 `.tmux.conf` 내용이 `keep`이며 `.tmux.conf.bak.*`이 없다.
  - `cp ... "$ROOT/tmux.conf"` 3곳(`test_repo_path_with_spaces`, `test_clone_into_config_dir_skips`, `copy_repo`)에서 `tmux.conf`를 뺀다.

  `tests/install.Tests.ps1`:
  - 새 `It 'Get-KnownComponent no longer lists tmux'` → `(Get-KnownComponent) -join ','`가 `'go,rust,java,lua'`.
  - `explicit tmux warns and is dropped`에 `($warnings -join ' ') | Should -Match 'WezTerm'`을 추가한다.
  - `Get-RequestedComponent validates names`의 `'lua,rust,tmux'` 기대는 그대로 둔다(tmux는 받되 `Resolve-Components`에서 뺀다).
- [ ] **Step 2: 실패 확인.** `bash tests/install_sh_test.sh` → 위 테스트들 FAIL. Pester: `Invoke-Pester tests/install.Tests.ps1 -Output Detailed` → 새 두 검사 FAIL.
- [ ] **Step 3: 구현.**
  - `install.sh`
    - `parse_args`의 `--with` 루프에서 `tmux`면 `err "경고: <경고 문구>"` 후 `continue`하고, `WITH_GIVEN=1`로 둔다.
    - tmux 전용 분기(`pkg_names`, `install_optional`, `link_configs`)와 usage의 `tmux,`를 지운다.
  - `install.ps1`
    - `Get-KnownComponent`에서 `'tmux'`를 뺀다.
    - `Get-RequestedComponent`는 `'tmux'`를 알 수 없는 항목으로 보지 않고 통과시킨다.
    - `Resolve-Components`에서 `-ne 'tmux'` 분기를 지우고, 경고를 새 문구로 바꾼다. 결과에서 tmux는 빠진다.
    - 도움말 `.PARAMETER`의 tmux 문장도 같은 내용으로 고친다.
  - `ci.yml`은 Files에 적은 대로 바꾼다.
- [ ] **Step 4: 통과 확인.**
  - `bash tests/install_sh_test.sh` → `실패 0`.
  - `shellcheck install.sh tests/*.sh` → 출력 없음.
  - Pester 전체 PASS.
  - `Invoke-ScriptAnalyzer -Path install.ps1 -Severity Warning,Error` → 결과 없음.
- [ ] **Step 5: 커밋.** `git commit -m "mod: 설치 스크립트에서 tmux를 빼고 --with tmux는 경고 후 건너뜀"`

### Task 5: 문서 정리와 tmux 파일 삭제

**Files:**
- Delete: `tmux.conf`, `docs/tmux.md` (tmuxinator 문서 포함)
- Create: `docs/wezterm.md`
- Modify: `README.md` (3, 19, 35~55, 140~150, 168, 204, 215, 274, 288~297, 385행 부근 + 문제 해결에 `### 예전 tmux 설정 정리`)
- Modify: `docs/keymaps.md:53,179,182`
- Modify: `tests/docs_test.sh`

**Interfaces:**
- `docs/wezterm.md` 필수 내용
  - 왜 tmux 대신 WezTerm인가.
  - 시작과 유지: unix domain 자동 연결, `prefix` + `d`, X 버튼 동작(Task 1 결과 그대로), mux 서버 프로세스 이름.
  - 키 표: 기존 tmux.md의 Windows 표 + `prefix` + `d` + `C-h/j/k/l` + `A-h/j/k/l` + `prefix` + `C-l`.
  - `탭 바에 보이는 번호` 문구를 유지한다.
  - tmux와 다른 점: 세션 목록·tmuxinator 없음, 상태줄 위젯 없음(PREFIX만, `OneDark (base16)`), 재부팅 후 복원 없음.
  - 설정을 바꾼 뒤 mux 서버 다시 시작하는 방법.
  - 문제가 생기면 `default_gui_startup_args` 줄을 주석 처리해 로컬 모드로 돌아가는 방법.

- [ ] **Step 1: 실패하는 테스트 작성.** `tests/docs_test.sh`:
  - `TMUX_DOC`를 `WEZTERM_DOC="$ROOT/docs/wezterm.md"`로 바꾼다.
  - `test_tmux_doc_windows_wezterm_keys`를 `test_wezterm_doc`로 바꾼다.
    - 문서에 `prefix` + `"` / `%`, `` `prefix` + `d` ``, `` `C-h/j/k/l` ``, `` `prefix` + `C-l` ``, `default_gui_startup_args`, `OneDark (base16)`, `탭 바에 보이는 번호`, `다시 시작`이 있어야 한다.
    - README에 `(docs/wezterm.md)`가 있어야 한다. 기존 wezterm.lua grep 두 줄(leader, zero_based)은 유지한다.
  - `test_tmux_doc_terminal_setting`을 삭제한다.
  - `test_relative_links_exist`의 `TMUX_DOC`를 `WEZTERM_DOC`로 바꾼다.
  - `test_legacy_files_removed`의 목록에 `tmux.conf docs/tmux.md`를 추가한다.
  - 새 `test_no_tmux_leftovers`
    - README, `docs/keymaps.md`에 `tmux.nvim`, `(tmux.conf)`, `docs/tmux.md`, `Neovim(+ tmux)`, `--with tmux,`가 없어야 한다.
    - README에 수동 정리 안내 `~/.tmux.conf`와 `~/.tmux/plugins`가 있어야 한다.
- [ ] **Step 2: 실패 확인.** `bash tests/docs_test.sh` → `test_wezterm_doc`, `test_legacy_files_removed`, `test_no_tmux_leftovers` FAIL.
- [ ] **Step 3: 구현.**
  - `git rm tmux.conf docs/tmux.md`, `docs/wezterm.md`를 작성한다.
  - README
    - 소개 문구를 "Neovim 개인 설정(WezTerm 멀티플렉서 포함)"으로 고친다.
    - tmux 행과 tmux 섹션을 지운다. 선택 항목 표 아래에 "`tmux`는 더 이상 선택 항목이 아니며 `--with tmux`는 경고 후 건너뜁니다"와 docs 링크를 둔다.
    - 예시를 `--with go,rust`로 바꾼다.
    - "### 예전 tmux 설정 정리"에 `rm ~/.tmux.conf`, `rm -rf ~/.tmux/plugins`를 적고 "설치 스크립트는 지우지 않습니다"라고 밝힌다.
  - keymaps.md의 플러그인 열을 `wezterm_nav`로, 설명을 "nvim 창, WezTerm 패널 사이 이동"으로 바꾸고, 링크를 `[WezTerm 사용법](wezterm.md)`로 바꾼다.
- [ ] **Step 4: 통과 확인.**
  - `bash tests/docs_test.sh` → `실패 0`.
  - `git grep -n -i tmux -- ':!docs/superpowers'`의 남은 줄이 다음뿐인지 눈으로 확인한다: 경고 문구, 테스트, README 정리 안내, wezterm.md의 비교 설명, `WEZTERM_UNIX_SOCKET` 같은 무관한 줄.
- [ ] **Step 5: 커밋.** `git commit -m "docs: tmux 문서와 설정을 지우고 WezTerm 멀티플렉서 사용법으로 교체"`

### Task 6: 로컬 수동 확인과 PR

- [ ] **Step 1: 전체 자동 검사.** `bash tests/install_sh_test.sh && bash tests/docs_test.sh && bash tests/run_lua.sh`, Pester, luacheck, stylua, shellcheck → 모두 통과.
- [ ] **Step 2: 설정 적용.**
  - 실행 중인 mux 서버를 끈다 (Task 1에서 기록한 프로세스 이름). 이 작업은 사용자의 열린 작업을 끝내므로 **사용자 확인 후** 진행한다.
  - WezTerm을 다시 연다.
- [ ] **Step 3: 설계 검증 1~5단계를 사용자와 함께 확인한다.** 분할·탭·`prefix` + 숫자 → `ping -t localhost` → `prefix` + `d` 후 재실행 → X 버튼 후 재실행 → nvim 창과 패널 사이 `C-h/j/k/l`, `A-h/j/k/l`. 각 단계 결과(통과/실패, 관찰 내용)를 기록한다.
- [ ] **Step 4: PR.** `git push -u origin feat/wezterm-replaces-tmux` 후 `gh pr create`. 본문에 다음을 넣는다.
  - 요약, 연동 방식 결정 근거(위 출처), 스파이크 결과, 수동 확인 결과 표.
  - macOS·Linux 실기기 미확인(Unknown).
  - 기존 PC의 tmux 파일 수동 정리 안내.
  - 끝에 `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.

## 스파이크 결과

(Task 1 Step 5에서 채운다)
