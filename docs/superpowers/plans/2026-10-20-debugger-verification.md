# 디버거 동작 보장 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Python, C/C++, Java 디버거가 설치 직후부터 동작하게 하고, "중단점에서 실제로 멈춘다"를 CI의 E2E 테스트로 보장한다.

**Architecture:** 디버그 어댑터는 mason-nvim-dap으로 설치만 맡기고(handlers 없음), 어댑터 설정은 지금처럼 직접 한다. 설치 대상 목록은 `configs.dap_adapters.list()`로 데이터화한다. LSP 목록(`configs.lsp_servers`)과 같은 방식이다. E2E 테스트는 headless nvim이 전체 설정으로 픽스처를 연 뒤, 마커 줄에 중단점을 걸고 `dap.run`으로 세션을 시작한다. 그다음 `stopped` 이벤트의 줄 번호가 마커 줄과 같은지 확인한다.

**Tech Stack:** nvim-dap, nvim-dap-ui, nvim-dap-python, mason.nvim, mason-nvim-dap.nvim, nvim-jdtls, codelldb, debugpy, java-debug-adapter, java-test, GitHub Actions

**Spec:** 별도 spec 문서 없음. 아래 "배경"이 2026-10-20 디버거 점검 결과이며 spec 역할을 한다.

## 배경 (점검 결과)

| # | 문제 | 근거 |
|---|---|---|
| 1 | 디버그 어댑터를 설치하는 곳이 없음 (codelldb, debugpy, java-debug-adapter, java-test) | 실측: mason에 0개. mason-lspconfig는 LSP만, mason-null-ls는 린터·포매터만 설치 |
| 2 | codelldb 경로 오류: 설정은 `packages/codelldb/codelldb(.exe)`, 실제는 `packages/codelldb/extension/adapter/codelldb(.exe)` | mason registry codelldb 정의 (v1.12.3, 모든 OS) |
| 3 | dap-python이 시스템 Python의 debugpy에 의존하고, 없으면 조용히 설정을 건너뜀 | 코드와 실측 |
| 4 | Java 디버그 번들이 없으면 빈 문자열 `""`이 bundles로 jdtls에 전달됨. nvim-jdtls는 번들(`vscode.java.startDebugSession`)이 있어야 DAP를 켬 | 코드, `nvim-jdtls/lua/jdtls/setup.lua` |
| 5 | rust 수동 설정(실행 파일 경로 입력)과 rustaceanvim 내장 DAP가 겹침 | rustaceanvim 소스 |
| 6 | dap-ui가 어댑터가 없는 lua/js/ts에서도 로드됨 | 코드 |

## Global Constraints

- Neovim 0.11 이상. Lua 들여쓰기 2칸, stylua(`.stylua.toml`)와 luacheck(`.luacheckrc`)를 통과해야 한다.
- 주석은 한국어, 이름은 영어. 함수화 최소화: 설치 목록과 설정은 데이터 테이블로 둔다.
- 커밋: 한국어 `type: 설명`, 끝에 `Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>`.
- PR: 최신 master에서 분기, squash merge, **머지는 사용자가 직접 실행**. 본문은 Summary, Commit Summary, Unit Test, Checklist 형식이고, CI 결과는 최신 SHA의 실행이 모두 끝난 뒤에만 적는다.
- 사용자에게 보이는 동작이 바뀌면 같은 PR에서 README와 `docs/keymaps.md`를 고치고, `tests/docs_test.sh`에 검사를 먼저 추가한다.
- 파일 편집은 줄바꿈을 보존하는 방식으로 한다(Python `read_bytes`/`write_bytes`, 또는 Edit 도구). `*.lua`는 LF로 고정되어 있다.
- 로컬 nvim 검증은 짧은 경로의 정션 `C:\Users\user\nvt\nvim`(→ 이 레포)과 `XDG_CONFIG_HOME=C:/Users/user/nvt`로 한다. 작업이 끝나면 정션을 지운다.
- 로컬에 어댑터를 설치하면 사용자의 공유 `nvim-data/mason`에 설치된다. 이 기능이 첫 실행 때 하는 일과 같으므로 허용한다.

## Review Focus

1. **어댑터 설치 전 첫 실행**(mason이 백그라운드로 받는 중)에 python/c/java 파일을 열어도 오류가 없어야 한다. 시작 스모크가 python 버퍼를 연다. Task 1에서 어댑터가 없는 상태의 스모크 통과를 확인한다.
2. **프로젝트 `.venv`가 있으면** 디버그 대상 프로그램은 그 venv의 python으로 실행돼야 하고, 없으면 시스템 python으로 실행돼야 한다. 어댑터용 debugpy venv로 실행되면 안 된다. Task 1의 `dap_python_spec`이 검사한다.
3. **Windows**에서도 어댑터 경로(`.exe`, `Scripts\python.exe`)가 맞아야 한다. Task 1과 Task 2의 경로 spec이 OS 분기를 둘 다 검사하고, E2E는 windows job에서도 돈다.
4. **java가 없는 환경**에서는 Java 어댑터를 설치하지 않아야 한다. bundles에 빈 문자열이 들어가면 안 된다. Task 1과 Task 3의 spec이 검사한다.
5. **E2E가 멈추지 않고 끝나야 한다**(타임아웃). E2E 스크립트는 모든 대기에 상한(기본 60초)을 두고, 초과하면 FAIL과 종료 코드 1을 낸다.

---

### Task 1 (PR 1): 어댑터 자동 설치와 Python 디버깅 — `feat/dap-python`

**Files:**
- Create:
  - `lua/configs/dap_adapters.lua`
  - `tests/lua/dap_adapters_spec.lua`, `tests/lua/dap_python_spec.lua`
  - `tests/dap_e2e.lua`, `tests/fixtures/dap/hello.py`
- Modify:
  - `lua/plugins/dap.lua`: mason-nvim-dap 스펙 추가, nvim-dap-python config 변경
  - `.github/workflows/ci.yml`: 3개 job에 어댑터 설치 단계와 `Python 디버거 E2E` 단계 추가
  - `README.md`: 설치되는 것, 첫 실행 안내, 문제 해결
  - `tests/docs_test.sh`
- 이 계획 문서도 이 PR에 포함한다.

**Interfaces:**
- Produces `configs.dap_adapters.list(executable?: fun(name): boolean) -> string[]`
  - mason-nvim-dap 이름을 돌려준다. 항상 `"python"`, `"codelldb"`이고, `java`가 있으면 `"javadbg"`, `"javatest"`를 추가한다.
  - 실행 시 mason-nvim-dap의 `mappings/source.lua`에서 이 이름이 각각 debugpy, codelldb, java-debug-adapter, java-test로 매핑되는지 확인한다. 다르면 Ruling으로 기록하고 실제 이름을 쓴다.
- Produces E2E 실행 방법: `nvim --headless <fixture> "+luafile tests/dap_e2e.lua"`
  - 마커 문자열 `BREAK`가 있는 첫 줄에 중단점을 건다.
  - `vim.bo.filetype`별 launch 설정으로 `dap.run`을 실행한다.
  - `stopped` 이벤트의 `session.current_frame.line`이 마커 줄과 같으면 `PASS dap <ft>`, 아니면 `FAIL dap <ft>: <이유>`를 출력하고 종료 코드 1.
  - Task 2와 Task 3은 이 파일의 `launch_configs` 테이블에 언어를 추가한다.
- dap-python 설정:
  - 어댑터 python은 mason debugpy venv: Windows `packages/debugpy/venv/Scripts/python.exe`, 그 밖의 OS `packages/debugpy/venv/bin/python`
  - 디버그 대상 python 순서: cwd의 `.venv`, 그다음 `venv` 안의 python, 없으면 `configs.paths.python()`
  - dap-python은 `resolve_python`이 지정되면 프로젝트 venv 자동 탐지를 건너뛰므로, 이 순서를 `resolve_python` 안에서 직접 구현한다.

- [ ] **Step 1: 실패 spec 작성**
  - `dap_adapters_spec`:
    - `list(function() return false end)`는 `{"python","codelldb"}`
    - `list(function(n) return n == "java" end)`에는 `"javadbg"`, `"javatest"`가 포함
  - `dap_python_spec`: dap-python과 mason을 대체(stub)한 뒤 dap.lua의 dap-python 스펙 `config()`를 실행하고 다음을 검사한다.
    - `setup` 인자가 OS별 debugpy venv python 경로로 끝남. `paths.is_windows`를 바꿔 가며 두 경우 모두 확인
    - 임시 cwd에 `.venv`를 만들면 `resolve_python()`이 그 venv의 python을 돌려줌
    - `.venv`가 없으면 `resolve_python()`이 `paths.python()`을 돌려줌
- [ ] **Step 2: 실패 확인.** `bash tests/run_lua.sh` → 두 spec FAIL
- [ ] **Step 3: 구현**
  - `lua/configs/dap_adapters.lua`
  - dap.lua에 mason-nvim-dap 스펙 추가: dependencies는 mason, nvim-dap. opts는 `ensure_installed = require("configs.dap_adapters").list()`, `automatic_installation = false`, `handlers = nil`
  - nvim-dap-python config를 위 설정대로 변경. debugpy venv가 아직 없으면 `vim.notify_once`로 "debugpy 설치 중" 안내를 WARN으로 한 번만 띄움
- [ ] **Step 4: 통과 확인.** run_lua 전체 PASS, 시작 스모크 PASS (어댑터 미설치 상태 — Review Focus 1)
- [ ] **Step 5: E2E 하네스와 python 픽스처 작성.** 픽스처는 `x = 1`, `y = x + 1  # BREAK`, `print(y)` 3줄이다.
- [ ] **Step 6: E2E RED 확인.** 어댑터 미설치 상태에서 `nvim --headless tests/fixtures/dap/hello.py "+luafile tests/dap_e2e.lua"` → FAIL. 이유는 어댑터 없음 또는 타임아웃이고, 60초 안에 끝나야 한다.
- [ ] **Step 7: 어댑터 설치 후 GREEN 확인.** `nvim --headless "+MasonInstall debugpy" +qa`(headless에서는 설치가 끝날 때까지 대기) 후 같은 명령 → `PASS dap python`
- [ ] **Step 8: CI 추가**
  - 3개 job에 `디버그 어댑터 설치` 단계: `nvim --headless "+MasonInstall debugpy codelldb" +qa` (ubuntu는 java 어댑터 2개 추가)
  - `Python 디버거 E2E` 단계 추가. windows는 `$LASTEXITCODE`를 검사한다.
- [ ] **Step 9: README와 docs_test.** docs_test에 필수 문구(`debugpy`, `codelldb`, `:Mason`)를 먼저 추가해 FAIL을 확인한 뒤 README를 고친다.
  - "설치되는 것"에 디버그 어댑터 추가
  - 첫 실행 안내에 "LSP 서버와 디버그 어댑터"
  - 문제 해결: 디버거가 시작되지 않으면 `:Mason`에서 설치 상태 확인
- [ ] **Step 10: 커밋, PR, CI 최종 확인.** 커밋은 `feat(dap): 디버그 어댑터 자동 설치와 Python 디버깅 복구`

### Task 2 (PR 2): C/C++ 디버깅 (codelldb 경로) — `fix/dap-codelldb`

**Files:**
- Modify: `lua/plugins/dap.lua` (codelldb 어댑터), `tests/dap_e2e.lua` (c 설정 추가), `.github/workflows/ci.yml`
- Create: `tests/lua/dap_codelldb_spec.lua`, `tests/fixtures/dap/hello.c`

**Interfaces:**
- Consumes: Task 1의 E2E 하네스(`launch_configs`), 어댑터 설치 단계
- codelldb 경로: `paths.exe(paths.mason_package("codelldb") .. "/extension/adapter/codelldb")`
- c launch 설정: E2E가 픽스처를 컴파일한 결과를 `program`으로 넘긴다. 컴파일러는 `cc`, `gcc`, `clang`, `zig cc` 중 처음 찾은 것을 `-g -O0`으로 쓴다.

- [ ] **Step 1: 실패 spec.** `dap_codelldb_spec`: nvim-dap-ui 스펙 `config()`를 dap/dapui를 대체(stub)해 실행한 뒤 `dap.adapters.codelldb.command`를 검사한다. Windows는 `/extension/adapter/codelldb.exe`, 그 밖의 OS는 `/extension/adapter/codelldb`로 끝나야 한다.
- [ ] **Step 2: E2E RED.** codelldb 설치 후 `nvim --headless tests/fixtures/dap/hello.c "+luafile tests/dap_e2e.lua"` → FAIL (어댑터 실행 실패)
- [ ] **Step 3: 경로 수정 → spec과 E2E GREEN**
- [ ] **Step 4: Windows 확인 (spike).** 로컬 Windows에서 `zig cc -g`로 만든 실행 파일로 E2E를 돌린다. 3번 시도해도 PDB 문제 등으로 멈추지 않으면 Ruling으로 기록한다. 그 경우 windows CI에서는 C E2E 대신 "codelldb 실행 파일이 있고 실행 가능한지"만 검사하고, C E2E는 ubuntu와 macOS에서 돌린다.
- [ ] **Step 5: CI `C 디버거 E2E` 단계, 커밋, PR.** 커밋은 `fix(dap): codelldb 실행 파일 경로 수정으로 C/C++ 디버깅 복구`

### Task 3 (PR 3): Java 디버깅 — `fix/dap-java`

**Files:**
- Modify: `ftplugin/java.lua` (bundles), `tests/lua/java_ftplugin_spec.lua`, `tests/dap_e2e.lua` (java 설정), `.github/workflows/ci.yml` (ubuntu만)
- Create: `tests/fixtures/dap/java/Hello.java`

**Interfaces:**
- bundles: glob 결과 중 빈 문자열을 제외한다. 디버그 번들이 없으면 bundles는 `{}`이고, `vim.notify_once`로 "java-debug-adapter가 없어 Java 디버깅을 사용할 수 없습니다"를 WARN으로 한 번만 띄운다.
- java launch: jdtls 연결과 `setup_dap`(nvim-jdtls가 번들을 보고 자동 실행)을 기다린다. 그다음 `require("jdtls.dap").setup_dap_main_class_configs()`로 `dap.configurations.java`를 채우고 `Hello`의 설정으로 실행한다.

- [ ] **Step 1: 실패 spec.** `java_ftplugin_spec`에 다음 검사를 추가한다.
  - 번들 jar가 없도록 glob을 대체하면 `config.init_options.bundles`가 빈 테이블
  - 같은 상황에서 WARN 안내가 1회
- [ ] **Step 2: 수정 → GREEN**
- [ ] **Step 3: Java E2E (spike, ubuntu).** 로컬(JDK 21 설치됨)에서 java-debug-adapter와 java-test를 설치하고 E2E를 실행한다.
  - jdtls 시작과 프로젝트 인식(invisible project)이 90초 안에 끝나지 않는 등 3번 시도해도 안정적이지 않으면 Ruling으로 기록한다.
  - 그 경우 대체 검사: jdtls 연결 후 `dap.adapters.java`가 등록되고 `vscode.java.startDebugSession` 명령이 노출되는지 확인한다.
- [ ] **Step 4: CI ubuntu에 `Java 디버거 E2E` 단계(타임아웃 넉넉히), 커밋, PR.** 커밋은 `fix(dap): Java 디버그 번들 처리와 Java 디버깅 검증`

### Task 4 (PR 4): 정리와 문서 — `refactor/dap-cleanup`

**Files:**
- Modify: `lua/plugins/dap.lua`, `docs/keymaps.md`, `README.md`, `tests/docs_test.sh`, `tests/startup_smoke.lua`

- [ ] **Step 1: 실패 검사 추가**
  - 스모크(c 버퍼): `require("dap").configurations.rust == nil` (rust는 rustaceanvim에 맡김). dap-ui `ft`에 lua/javascript/typescript가 없는지는 lazy 스펙으로 검사
  - docs_test: `docs/keymaps.md`에 `:RustLsp debuggables` 안내와 "디버그 어댑터" 문구
- [ ] **Step 2: 수정**
  - `dap.configurations.rust` 삭제. c와 cpp 설정은 유지한다. 지금은 `c = rust`로 같은 표를 공유하므로, 표를 `c`에 직접 정의하고 `cpp = c`로 바꾼다.
  - dap-ui와 dap-virtual-text의 `ft`를 `{ "c", "cpp", "rust", "python", "java" }`로 줄임
  - `docs/keymaps.md`의 디버깅 절에 언어별 시작 방법 표 추가: python/c/cpp는 `F5`, rust는 `:RustLsp debuggables`, java는 `F5`(main 클래스 자동 탐지)
- [ ] **Step 3: GREEN, 전체 테스트, 커밋, PR.** 커밋은 `refactor(dap): rust 디버깅을 rustaceanvim에 맡기고 디버거 문서 정리`

## 결정 사항 (계획 검토 때 확인)

1. 설치 방식은 mason-nvim-dap(설치만, handlers 없음)이다. 기존 mason-null-ls와 같은 저자·같은 방식이다.
2. codelldb와 debugpy는 항상 설치하고, Java 어댑터는 `java`가 있을 때만 설치한다.
3. E2E 범위:
   - Python: 3개 OS
   - C: ubuntu와 macOS. windows는 spike 결과에 따름
   - Java: ubuntu만
   - Rust: rustaceanvim이 같은 codelldb를 쓰므로 C E2E로 대신함
4. lua/js/ts 디버거는 이번 범위에서 제외한다(dap-ui 로드 대상에서도 뺌).

## 범위 밖

- lua(one-small-step-for-vimkind), js/ts(vscode-js-debug) 디버그 어댑터 추가
- 디버그 어댑터를 설치 스크립트 단계에서 미리 받기 (현재 LSP처럼 첫 실행 때 백그라운드 설치)
