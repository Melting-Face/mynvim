# nvim 설정 품질 개선 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 2026-10-20 설정 평가에서 나온 9개 항목을 PR 9개로 나눠 순서대로 고친다.

**Architecture:** 먼저 전체 설정으로 nvim을 띄워 검사하는 시작 스모크 테스트를 만든다. 이후 PR마다 그 스모크나 `tests/lua/*_spec.lua`에 실패하는 검사를 먼저 추가하고(TDD) 고친다. 구조 변경(plugins.lua 분할)과 포매팅은 버그 수정이 끝난 뒤에 해서 리뷰 diff를 작게 유지한다.

**Tech Stack:** Neovim 0.11+, lazy.nvim, mason.nvim / mason-lspconfig v2, nvim-lspconfig(`vim.lsp.config`), nvim-treesitter(master), GitHub Actions

**Spec:** 별도 spec 문서 없음. 아래 "배경"이 평가 결과 요약이며 spec 역할을 한다.

## 배경 (평가 결과 요약)

| # | 항목 | 핵심 근거 |
|---|---|---|
| 1 | LSP 0.11 경로 | `on_attach`/capabilities 미전달로 navic 미동작(실측). mason-lspconfig v2 `automatic_enable` 기본값 때문에 stylua LSP가 중복으로 붙음(실측). rust_analyzer/jdtls가 rustaceanvim/nvim-jdtls와 중복될 위험. 0.11 미만 분기는 실행되지 않는 코드 |
| 2 | 옵션 | `undofile=false`(실측), `fileencodings='utf8'`이라 cp949 파일이 깨짐(실측) |
| 3 | 무시/깨진 설정 | ruff `settings.args`는 ruff-lsp 형식이라 무시됨(Ruff Docs: Editor Settings). lualine `lsp_progress`/`tabnine`가 없어서 상태줄 파일명이 사라짐(실측). `cmp_git`, none-ls `refactoring`, `none-ls-extras`는 미사용. neogen의 `ipairs(lang_doc_map)` 루프는 실행되지 않음 |
| 4 | treesitter | `lazy=true`라 neogen 언어에서만 config가 실행되고, `highlight` 설정이 없음(yaml에서 실측) |
| 5 | 키맵 충돌 | `,a`(swap ↔ claude 그룹), `,dc/,dm`(dap-python ↔ jdtls 전역), `]d/[d`(진단 기본값 ↔ conditional), `gr`(0.11 `grr` 등과 충돌), `K`와 tabclose 중복, `j/k` count |
| 6 | 구조 | `lua/plugins.lua` 1070줄, 주석 처리된 refactoring 블록 |
| 7 | 재현성 | lock 파일 미커밋(설계 문서상 사용자 결정), `williamboman/*` → `mason-org/*` 이름 변경 |
| 8 | 품질 검사 | 시작 스모크 없음, CI에서 luacheck/stylua 미실행, `.stylua.toml` 없음 |
| 9 | 사소 | `vim.loop`, 옵션 중복, `encoding` 무효, mouse 주석 불일치, cindent/smartindent, tmux 트루컬러 |

## Global Constraints

- Neovim 최소 버전: 0.11 (CI `nvim 0.11 확인` 단계가 강제). 0.11 미만 호환 코드는 남기지 않는다.
- Lua 들여쓰기: 기존 레포 관례인 **스페이스 2칸** (사용자 전역 4칸 규칙은 Python용이며, 이 레포 Lua는 2칸으로 일관됨).
- 주석은 한국어, 변수와 함수명은 영어. 함수화 최소화: 설정은 데이터 테이블로 두고 helper 함수를 새로 만들지 않는다.
- 커밋 메시지: 한국어 `type: 설명` (type은 feat, fix, mod, add, del, docs, refactor, test 중 하나). 끝에 `Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>`.
- PR: 브랜치 하나당 PR 하나, 최신 master에서 분기, squash merge(기존 #2~#6 관례). 본문 끝에 `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
- **머지는 사용자 승인 후에만** 한다. 앞 PR이 머지된 뒤 다음 브랜치를 만든다.
- 로컬 검증은 작업 트리를 nvim 설정으로 쓰게 해서 실행한다 (로컬 `%LOCALAPPDATA%\nvim`은 다른 clone을 가리키는 정션이다):
  ```bash
  # 한 번만: 스크래치에 작업 트리를 가리키는 정션 생성
  powershell -NoProfile -Command "New-Item -ItemType Junction -Path \"$SCRATCH/cfg/nvim\" -Target \"$PWD\""
  # 이후 모든 로컬 nvim 검증 명령 앞에 붙임 (플러그인은 기존 nvim-data를 재사용)
  XDG_CONFIG_HOME="$SCRATCH/cfg" nvim ...
  ```
  `$SCRATCH`는 세션 스크래치 디렉터리다.
- **README 동기화 (2026-10-20 사용자 요청):** 키바인딩이나 사용자에게 보이는 동작이 바뀌는 PR은 같은 PR에서 `README.md`의 "주요 키맵 및 팁" 표와 설명을 함께 고친다. 바뀐 키와 문구는 먼저 `tests/docs_test.sh`의 필수 문구 검사에 추가해 FAIL을 확인한 뒤 README를 고친다. 대상은 Task 2(undo 보존, cp949), Task 3(ruff 규칙, LSP 기본 키), Task 5(`,sn`/`,sp`, `]i`/`[i`, `]d`/`[d`), Task 6(`grr`, `K`, `,dc`/`,dm`)이다.
- **전체 키맵 문서 (2026-10-20 사용자 요청):** README에는 "자주 쓰는 키" 표만 두고, 전체 키바인딩은 `docs/keymaps.md`에 플러그인과 용도별로 정리한다. README "주요 키맵 및 팁" 절에서 이 문서로 링크한다. Task 5에서 만들고(변경 후 상태 기준), Task 6과 Task 7에서 갱신한다. `docs_test.sh`는 이 문서의 상대 링크 검사(`check_links`)와 필수 키 문구 검사를 포함한다.
- 기존 테스트(`tests/run_lua.sh`, `tests/docs_test.sh`, `tests/install_sh_test.sh`, Pester)는 모든 PR에서 계속 통과해야 한다.

## Review Focus

1. **처음 설치 직후 첫 실행**(플러그인, 파서, LSP 서버가 아직 설치 중)에도 오류 메시지가 없어야 한다. CI는 매번 새로 설치하므로, Task 1의 스모크를 CI 3개 job에서 돌려 고정한다.
2. **Windows(pwsh/powershell 5.1)**에서도 같은 스모크가 통과해야 한다. Task 1에서 windows job에도 추가한다.
3. **cp949로 저장된 한글 파일**은 깨지지 않고 열려야 하며, ASCII/UTF-8 파일은 계속 utf-8로 인식돼야 한다. Task 2 spec에 두 경우를 다 넣는다.
4. **python 버퍼와 java 버퍼에서 각각 `,dc`**가 자기 언어의 테스트를 실행해야 한다. Task 6 스모크에서 python 버퍼의 desc를 확인하고, c 버퍼에서는 매핑이 없음을 확인한다.
5. **mason 이름 변경 후 기존 설치본**에서 `:Lazy sync`를 해도 플러그인이 중복되거나 사라지지 않아야 한다. Task 8의 로컬 검증 단계에서 확인한다.

---

### Task 1 (PR 1): 시작 스모크 테스트 추가 — `test/startup-smoke`

**Files:**
- Create: `tests/startup_smoke.lua`, `tests/fixtures/smoke.c`, `tests/fixtures/smoke.py`
- Modify: `.github/workflows/ci.yml` (unix, distros, windows job의 `treesitter 스모크` 다음에 단계 추가)
- 이 계획 문서도 이 PR에 포함한다.

**Interfaces:**
- Produces: 실행 방법 `nvim --headless tests/fixtures/smoke.c "+luafile tests/startup_smoke.lua"`. 성공하면 `PASS startup` 출력과 종료 코드 0, 실패하면 `FAIL startup: <이유>`와 종료 코드 1. 이후 Task들은 이 파일의 `-- 검사 목록` 구역에 assert를 추가한다.

- [ ] **Step 1: 스모크 작성.** 구조는 `tests/treesitter_smoke.lua`와 같게 `fail(msg)`로 `cquit 1` 한다. `vim.wait(2000)`으로 VimEnter와 lazy 이벤트가 처리되기를 기다린 뒤 아래를 검사한다.
  - `vim.v.errmsg == ""`
  - `nvim_exec2("messages")` 출력에 `E%d+:`나 `Error`가 없음
  - 픽스처: `smoke.c`에는 `int main(void) { if (1) { return 0; } return 1; }`, `smoke.py`에는 `def f():\n    return 1\n`
- [ ] **Step 2: 로컬 실행.** `XDG_CONFIG_HOME=... nvim --headless tests/fixtures/smoke.c "+luafile tests/startup_smoke.lua"` → `PASS startup`. 실패하면 그 오류가 새로 발견된 버그이므로 계획에 추가한다.
- [ ] **Step 3: CI 단계 추가.** 이름은 `시작 스모크`, 명령은 위와 같다. windows job에는 기존 관례대로 `if ($LASTEXITCODE -ne 0) { exit 1 }`를 붙인다.
- [ ] **Step 4: 커밋, 푸시, PR, CI 확인.** 커밋은 `test: 전체 설정 시작 스모크 테스트 추가`. `gh pr checks --watch`로 CI 통과를 확인한 뒤 사용자 머지 승인을 기다린다.

### Task 2 (PR 2): undo 기록 보존과 인코딩 감지 — `fix/options-undo-encoding`

**Files:**
- Modify: `lua/configs/options.lua`, `init.lua:4`
- Test: `tests/lua/options_spec.lua`

- [ ] **Step 1: spec에 실패 검사 추가** (`options_spec.lua`, `require("configs.options")` 다음)
  ```lua
  assert(vim.o.undofile, "undofile이 켜져 있어야 함")
  assert(vim.o.fileencodings == "ucs-bom,utf-8,cp949,latin1", vim.o.fileencodings)
  assert(not vim.o.cindent and not vim.o.smartindent, "indent는 filetype/treesitter에 맡김")
  -- cp949 파일은 cp949로, ASCII 파일은 utf-8로 열려야 함
  local cp949 = vim.fn.tempname()
  vim.fn.writefile({ vim.iconv("한글", "utf-8", "cp949") }, cp949, "b")
  vim.cmd.edit(cp949)
  assert(vim.bo.fileencoding == "cp949" and vim.api.nvim_get_current_line() == "한글")
  local ascii = vim.fn.tempname()
  vim.fn.writefile({ "abc" }, ascii)
  vim.cmd.edit(ascii)
  assert(vim.bo.fileencoding == "utf-8", vim.bo.fileencoding)
  ```
- [ ] **Step 2: 실패 확인.** `bash tests/run_lua.sh` → `FAIL tests/lua/options_spec.lua`
- [ ] **Step 3: `options.lua` 수정**
  - `vim.o.undofile = true` 추가 (undodir 설정 바로 아래)
  - `fileencodings = 'ucs-bom,utf-8,cp949,latin1'`
  - 다음 줄 삭제: `cindent`, `smartindent`, 중복된 `ts`, 두 번째 `shiftwidth`, `encoding`
  - mouse 주석을 실제 값에 맞게 수정: `-- mouse는 hit-enter/more 프롬프트에서만 사용`
  - `init.lua`의 `vim.loop.fs_stat`를 `vim.uv.fs_stat`로 변경
- [ ] **Step 4: 통과 확인.** `bash tests/run_lua.sh` 전체 PASS. 시작 스모크도 PASS.
- [ ] **Step 5: 커밋과 PR.** `fix(options): undo 기록 보존과 cp949 파일 인코딩 감지`

### Task 3 (PR 3): LSP 설정을 nvim 0.11 방식으로 정리 — `fix/lsp-native-config`

**Files:**
- Modify: `lua/configs/lsp_servers.lua`, `lua/plugins.lua` (mason-lspconfig spec 659–667, nvim-cmp spec 824–1045)
- Test: `tests/lua/lsp_servers_spec.lua`

**Interfaces:**
- Produces (`configs.lsp_servers`):
  - `M.list(executable)`: 기존 그대로
  - `M.settings`: `table<string, vim.lsp.Config>`. 키는 `lua_ls`, `pyright`, `ruff`, `yamlls`이고 값은 현재 0.11 분기의 설정을 그대로 옮긴다. ruff만 아래 형식으로 바꾼다.
  - `M.automatic_enable_exclude`: `{ "jdtls", "rust_analyzer", "stylua" }`
- ruff 설정 (Ruff Docs: Editor Settings, `lint.extendSelect`/`lint.ignore`):
  ```lua
  init_options = { settings = { lint = {
    extendSelect = { "AIR", "B", "C4", "C90", "E", "F", "FURB", "G", "I", "LOG", "NPY", "PD", "Q", "SIM", "T20", "UP" },
    ignore = { "PD901" },
  } } }
  ```

- [ ] **Step 1: spec에 실패 검사 추가** (`lsp_servers_spec.lua`)
  ```lua
  local ruff = servers.settings.ruff.init_options.settings
  assert(ruff.args == nil, "ruff server는 args를 지원하지 않음")
  assert(vim.tbl_contains(ruff.lint.extendSelect, "B") and vim.tbl_contains(ruff.lint.extendSelect, "PD"))
  assert(vim.deep_equal(ruff.lint.ignore, { "PD901" }))
  assert(servers.settings.lua_ls.settings.Lua.diagnostics.globals[1] == "vim")
  for _, name in ipairs({ "jdtls", "rust_analyzer", "stylua" }) do
    assert(vim.tbl_contains(servers.automatic_enable_exclude, name), name)
  end
  ```
- [ ] **Step 2: 실패 확인.** `bash tests/run_lua.sh` → lsp_servers_spec FAIL
- [ ] **Step 3: `lsp_servers.lua`에 `M.settings`와 `M.automatic_enable_exclude` 추가**
- [ ] **Step 4: mason-lspconfig spec을 `config = function(_, opts)`로 바꿈.** `plugins.lua` 1행은 `local servers = require("configs.lsp_servers")`와 `local language_servers = servers.list()` 두 줄로 바꾼다. config 안의 순서는 다음과 같다.
  1. `vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })`
  2. `M.settings`의 각 항목마다 `vim.lsp.config(name, cfg)`
  3. `LspAttach` autocmd(group `UserNavic`)를 만들어 `client.server_capabilities.documentSymbolProvider`가 있으면 `require("nvim-navic").attach(client, ev.buf)`
  4. `require("mason-lspconfig").setup(opts)`
  - opts는 `{ ensure_installed = language_servers, automatic_enable = { exclude = servers.automatic_enable_exclude } }`이고 `automatic_installation`은 삭제한다.
  - dependencies에 `williamboman/mason.nvim`, `hrsh7th/cmp-nvim-lsp`, `SmiteshP/nvim-navic`를 추가한다.
- [ ] **Step 5: nvim-cmp config에서 LSP 관련 코드 삭제.** 대상은 `navic`, `on_attach`, `capabilities`, 버전 분기 두 개(896–1043)다. dependencies에서 `neovim/nvim-lspconfig`, `SmiteshP/nvim-navic`를 빼서 cmp는 자동완성만 담당하게 한다.
- [ ] **Step 6: 통과 확인.** `bash tests/run_lua.sh` 전체 PASS, 시작 스모크 PASS.
- [ ] **Step 7: 로컬 실측.** lua 파일을 열고 8초 기다린 뒤 다음을 확인한다.
  - 클라이언트 이름 목록이 `{lua_ls, null-ls}`이고 `stylua`가 없음
  - `require("nvim-navic").is_available()`가 `true`
  - python 파일에서 `ruff` 클라이언트의 `config.init_options.settings.lint.extendSelect`에 값이 있음
- [ ] **Step 8: 커밋과 PR.** `fix(lsp): 0.11 설정에서 navic·capabilities 누락과 서버 중복 실행 수정`

### Task 4 (PR 4): 없는 플러그인 참조와 죽은 코드 제거 — `fix/broken-plugin-refs`

**Files:**
- Modify: `lua/plugins.lua` (lualine 732, cmp gitcommit 868–874, none-ls 349–371, neogen 293–316), `README.md` (플러그인 목록에서 none-ls-extras 삭제)
- Create: `tests/lua/dead_refs_spec.lua` (`no_home_spec.lua`와 같은 방식으로 금지 문자열 검사)
- Test: `tests/startup_smoke.lua`

- [ ] **Step 1: 실패 검사 추가**
  - `dead_refs_spec.lua`: `lua/`와 `ftplugin/`의 lua 파일 어디에도 `"lsp_progress"`, `"tabnine"`, `"cmp_git"`, `code_actions.refactoring`, `none-ls-extras`, `ipairs(lang_doc_map)`가 없어야 한다.
  - 스모크: `vim.api.nvim_eval_statusline(vim.o.statusline, {}).str`에 `smoke.c`가 포함돼야 한다.
- [ ] **Step 2: 실패 확인.** spec과 스모크가 모두 FAIL
- [ ] **Step 3: 수정**
  - lualine: `sections = { lualine_x = { "lsp_status", "encoding", "fileformat", "filetype" } }`. `lsp_status`는 lualine 내장 컴포넌트이고, lualine_c는 기본값(filename)으로 둔다.
  - cmp: `cmp.setup.filetype("gitcommit", ...)` 블록 삭제
  - none-ls: `code_actions.refactoring` 줄과 `nvimtools/none-ls-extras.nvim` 의존성 삭제
  - neogen: `lang_doc_map`과 루프를 삭제하고 `require("neogen").setup({ enabled = true, snippet_engine = "luasnip" })`만 남김
- [ ] **Step 4: 통과 확인.** run_lua, docs_test, 스모크 모두 PASS
- [ ] **Step 5: 커밋과 PR.** `fix(plugins): 설치되지 않은 플러그인 참조와 실행되지 않는 neogen 루프 제거`

### Task 5 (PR 5): treesitter를 모든 파일에서 로드하고 하이라이트 켜기 — `fix/treesitter-loading`

**Files:**
- Modify: `lua/plugins.lua` (treesitter 180–276), `README.md` (키맵 표에 swap 키가 있으면 갱신)
- Test: `tests/startup_smoke.lua`

- [ ] **Step 1: 스모크에 실패 검사 추가** (c 버퍼 기준. c 파서는 nvim에 내장되어 CI 설치 상태와 관계없다)
  ```lua
  assert(vim.treesitter.highlighter.active[buf], "treesitter 하이라이트")
  assert(vim.fn.maparg(",sn", "n") ~= "", "swap next 키")
  assert(vim.fn.maparg(",a", "n", false, true).buffer ~= 1, ",a는 버퍼 로컬 swap이 아니어야 함")
  assert((vim.fn.maparg("]d", "n", false, true).desc or ""):lower():find("diagnostic"), "]d는 진단 이동")
  assert(vim.fn.maparg("]i", "n") ~= "", "conditional 이동은 ]i")
  ```
- [ ] **Step 2: 실패 확인.** 스모크 FAIL (하이라이트 비활성)
- [ ] **Step 3: 수정**
  - `lazy = true`를 `event = { "BufReadPost", "BufNewFile" }`로 변경
  - `highlight = { enable = true }` 추가, `sync_install = false`
  - swap 키를 `<leader>a`/`<leader>A`에서 `<leader>sn`/`<leader>sp`로 변경
  - `goto_next`/`goto_previous`의 `]d`/`[d`를 `]i`/`[i`로 변경 (`[i`의 기본 기능인 키워드 첫 줄 표시는 덮어쓴다)
- [ ] **Step 4: 통과 확인.** 스모크와 treesitter 스모크 PASS. 로컬에서 yaml 파일의 `highlighter.active`가 true인지 확인한다.
- [ ] **Step 5: 커밋과 PR.** `fix(treesitter): 모든 파일에서 로드하고 하이라이트와 키 충돌 수정`

### Task 6 (PR 6): 키맵 충돌 정리 — `fix/keymap-conflicts`

**Files:**
- Modify: `lua/configs/keymaps.lua`, `lua/plugins.lua` (dap-python keys 620–636, jdtls keys 642–657), `README.md` (자주 쓰는 키 표에서 `gr`를 `grr`로)
- Create: `tests/lua/keymaps_spec.lua` (`package.loaded["which-key"] = { add = function() end }`로 대체한 뒤 `require("configs.keymaps")`)
- Test: `tests/startup_smoke.lua`

- [ ] **Step 1: 실패 검사 추가**
  - spec:
    - `maparg("j","n",false,true).rhs == [[v:count == 0 ? 'gj' : 'j']]` (k도 같은 형식)
    - `nvim_exec_autocmds("LspAttach", { buffer = buf, data = { client_id = 0 } })` 실행 후
      - `maparg("gr","n",false,true).buffer ~= 1`
      - `maparg("K","n",false,true).buffer ~= 1`
      - `maparg("gd","n",false,true).buffer == 1`
    - `maparg(",tc","n") == ""`
  - 스모크:
    - c 버퍼에서 `maparg(",dc","n") == ""`
    - `vim.cmd.edit("tests/fixtures/smoke.py")`로 python 버퍼를 연 뒤 `maparg(",dc","n",false,true).desc == "python test class"`
- [ ] **Step 2: 실패 확인.**
- [ ] **Step 3: 수정**
  - `keymaps.lua`:
    - j/k를 `v:count == 0 ? 'gj' : 'j'` 형식으로 변경
    - LspAttach 안의 `K` 두 줄과 `gr` 삭제 (0.11 기본 `K`, `grr` 사용)
    - `,tc` 삭제 (`<space>tx`와 중복)
  - dap-python keys: `ft = "python"` 추가, desc를 `python test class` / `python test method`로
  - jdtls keys: `ft = "java"` 추가, desc를 `java test class` / `java test nearest method`로
- [ ] **Step 4: 통과 확인.**
- [ ] **Step 5: 커밋과 PR.** `fix(keymaps): 언어별 테스트 키 분리와 0.11 기본 LSP 키 충돌 정리`

### Task 7 (PR 7): `lua/plugins.lua`를 주제별 파일로 분할 — `refactor/split-plugins`

**Files:**
- Delete: `lua/plugins.lua`
- Create: `lua/plugins/` 아래 파일들. 각 파일은 spec 목록을 `return`한다.
  - `editor.lua`: devicons, plenary, tabular, startify, visual-multi, better-whitespace, undotree, todo-comments, tmux.nvim, hop, spectre, telescope, text-case, pqf, bqf, Comment, surround, nvim-tree, neogen
  - `ui.lua`: catppuccin, which-key, indent-blankline, bufferline, scope, navic, lualine
  - `git.lua`: fugitive, neogit, gitsigns, git-conflict
  - `data.lua`: rainbow_csv, csv.vim, dadbod-ui
  - `treesitter.lua`: nvim-treesitter
  - `lsp.lua`: mason, none-ls, mason-null-ls, mason-lspconfig, rustaceanvim, nvim-jdtls, nvim-cmp. 파일 맨 위에 `local language_servers`
  - `dap.lua`: dap-ui, dap-virtual-text, dap-python. 파일 맨 위에 `local filetypes`
  - `ai.lua`: claudecode
- Modify:
  - `README.md`: 링크 `lua/plugins.lua`를 `lua/plugins/`로
  - `tests/docs_test.sh:87`: 검사 대상 파일을 `lua/plugins/treesitter.lua`로
- 주석 처리된 refactoring 블록(742–816)은 옮기지 않고 삭제한다. `init.lua`의 `setup('plugins', ...)`는 그대로 둔다 (lazy.nvim이 `lua/plugins/*.lua`를 자동으로 합친다).

- [ ] **Step 1: 분할 전 스냅샷.** 로컬 headless에서 정렬한 `name|lazy|event|ft|keys(lhs,mode,ft)` 목록을 `$SCRATCH/before.txt`로 저장한다. 대상은 `require("lazy.core.config").spec.plugins`이다.
- [ ] **Step 2: 파일 분할** (코드는 옮기기만 하고 바꾸지 않는다)
- [ ] **Step 3: 동일성 확인.** 같은 명령으로 `$SCRATCH/after.txt`를 만들고 `diff before.txt after.txt`가 비어 있어야 한다.
- [ ] **Step 4: 전체 테스트.** run_lua, docs_test, 시작 스모크, treesitter 스모크 모두 PASS
- [ ] **Step 5: 커밋과 PR.** `refactor(plugins): plugins.lua를 주제별 파일로 분할`

### Task 8 (PR 8): 저장소 이름 변경 반영과 tmux 트루컬러 — `fix/minor-cleanups-3`

**Files:**
- Modify:
  - `lua/plugins/lsp.lua`: `williamboman/mason.nvim` → `mason-org/mason.nvim`, `williamboman/mason-lspconfig.nvim` → `mason-org/mason-lspconfig.nvim`, `jayp0521/mason-null-ls.nvim` → `jay-babu/mason-null-ls.nvim`. dependencies 문자열까지 **모두** 바꾼다.
  - `README.md` 링크 3곳
  - `tmux.conf`: `default-terminal "screen-256color"`, `set -ga terminal-overrides ",*256col*:Tc"`
- Test: `tests/lua/dead_refs_spec.lua`에 금지 문자열 `williamboman/`, `jayp0521/` 추가
- Modify (실행 중 추가): `ftplugin/java.lua`, Test: `tests/lua/java_ftplugin_spec.lua`

- [ ] **Step 0 (실행 중 추가 발견): Windows jdtls 경로.** `ftplugin/java.lua`가 Windows에서 없는 파일 `packages/jdtls/bin/jdtls.cmd`를 찾아 Java LSP가 시작되지 않는다. mason이 만드는 래퍼는 `packages/jdtls/jdtls.cmd`이고, `bin/jdtls.bat`에는 `pause`가 있어 쓸 수 없다. `java_ftplugin_spec.lua`에 다음 검사를 먼저 추가해 FAIL을 확인한 뒤 고친다: Windows이면 `cmd[1]`이 `/jdtls.cmd`로 끝나고 `/bin/`을 포함하지 않으며, 그 밖의 OS이면 `/bin/jdtls`로 끝난다.
- [ ] **Step 1: spec에 금지 문자열 추가 → FAIL 확인**
- [ ] **Step 2: 수정 → run_lua PASS**
- [ ] **Step 3: 로컬 실측.** `XDG_CONFIG_HOME=... nvim --headless "+Lazy! sync" +qa`를 실행한 뒤 다음을 확인한다.
  - `nvim-data/lazy/mason.nvim`의 `git remote get-url origin`이 mason-org를 가리킴
  - 시작 스모크 PASS
  - `:Lazy`에 같은 이름의 중복 항목이 없음
- [ ] **Step 4: 커밋과 PR.** `fix: mason 저장소 이름 변경 반영과 tmux 트루컬러 설정`
- lock 파일 커밋 여부는 사용자 결정 사항이다 (아래 "결정 필요" 참고). 결정이 바뀌면 이 PR에 `.gitignore` 수정과 README "버전 고정 파일" 문구 수정을 포함한다.

### Task 9 (PR 9): CI에 luacheck와 stylua 검사 추가 — `test/lint-format`

**Files:**
- Create: `.stylua.toml` (`column_width = 120`, `indent_type = "Spaces"`, `indent_width = 2`, `quote_style = "AutoPreferDouble"`)
- Modify:
  - `.luacheckrc`: `std = "luajit"`, `max_line_length = false` 추가
  - `.github/workflows/ci.yml`: 새 `lint` job (ubuntu-latest)
  - 포매팅 대상 Lua 파일 전체
- CI `lint` job:
  - `sudo apt-get install -y lua-check` 후 `luacheck init.lua lua ftplugin tests wezterm.lua`
  - `JohnnyMorganz/stylua-action@v4`에 `token: ${{ secrets.GITHUB_TOKEN }}`, `version:`은 로컬 mason의 `stylua --version` 값으로 고정, `args: --check .`

- [ ] **Step 1: CI job과 설정 파일 추가.** 로컬 `stylua --check .`(mason bin) → 차이가 있으면 FAIL
- [ ] **Step 2: 포매팅만 하는 커밋.** `stylua .` 실행 후 `refactor: stylua로 Lua 코드 포매팅`. 동작 변경이 없음을 시작 스모크와 run_lua로 확인한다.
- [ ] **Step 3: luacheck 경고 수정.** CI 결과(로컬에 luacheck가 없음)를 보고 고친다. 경고 중 동작에 영향이 있는 것은 PR 본문에 따로 적는다.
- [ ] **Step 4: 커밋과 PR.** `test: CI에 luacheck·stylua 검사 추가`

## 결정 사항 (2026-10-20 사용자 확인)

1. lazy-lock.json은 계속 커밋하지 않는다 (Task 8에서 `.gitignore`를 바꾸지 않음).
2. `]d/[d` → `]i/[i`, swap → `,sn/,sp`, `gr` → `grr` 키 변경을 그대로 적용한다.
3. `cindent`/`smartindent`를 제거한다.
4. 실행 방식은 Native, PR마다 CI 통과 후 사용자 승인을 받고 squash merge한다.

## 범위 밖 (이번에 하지 않음)

- 시작 시 즉시 로드되는 플러그인 수(41/61) 튜닝. treesitter 외에는 측정 근거 없이 바꾸지 않는다.
- `timeoutlen = 2500` 변경 (개인 취향)
- rainbow_csv와 csv.vim 중복, nvim-treesitter master 동결 대응(main 이전)
