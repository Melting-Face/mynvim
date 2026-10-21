#!/usr/bin/env bash
# 문서 검증 테스트 (순수 bash, bash 3.2 호환)
# README 구조, 필수 문구, 상대 링크, 삭제된 파일, .gitignore를 확인한다.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README="$ROOT/README.md"
WEZTERM_DOC="$ROOT/docs/wezterm.md"

# 실패 시 서브셸(테스트 하나)을 즉시 종료한다
fail() {
    echo "    FAIL: $*" >&2
    exit 1
}

# assert_file_contains <파일> <고정 문자열>
assert_file_contains() {
    [ -f "$1" ] || fail "파일이 없음: $1"
    grep -qF -- "$2" "$1" || fail "$1 에 '$2' 가 없음"
}

test_readme_sections_in_order() {
    local titles="소개|터미널 준비(WezTerm)|빠른 시작|설치 옵션|설치되는 것|주요 키맵|플러그인 목록|문제 해결|백업 복구"
    local last=0 title line IFS_BAK="$IFS"
    [ -f "$README" ] || fail "README.md 없음"
    IFS='|'
    for title in $titles; do
        IFS="$IFS_BAK"
        line="$(grep -nE "^## .*$(printf '%s' "$title" | sed 's/[()]/\\&/g')" "$README" | head -n 1 | cut -d: -f1)"
        [ -n "$line" ] || fail "섹션 제목 없음: $title"
        [ "$line" -gt "$last" ] || fail "섹션 순서가 틀림: $title"
        last="$line"
        IFS='|'
    done
    IFS="$IFS_BAK"
}

test_readme_required_phrases() {
    local phrase
    for phrase in 'brew install --cask wezterm' 'winget install wez.wezterm' 'WezTerm 기준' \
        '--with' '-With' 'ExecutionPolicy' 'WEZTERM_CONFIG_FILE'; do
        assert_file_contains "$README" "$phrase"
    done
}

test_readme_windows_followability() {
    local phrase
    # winget 준비, 새 PowerShell 창 안내, PowerShell 7 설치, PowerShell dry-run 예시
    for phrase in 'https://aka.ms/getwinget' '새 PowerShell 창' 'Microsoft.PowerShell' \
        '.\install.ps1 -DryRun -Yes'; do
        assert_file_contains "$README" "$phrase"
    done
}

test_readme_linux_git_install() {
    local phrase
    for phrase in 'sudo apt install -y git' 'sudo dnf install -y git' 'sudo pacman -S --needed git'; do
        assert_file_contains "$README" "$phrase"
    done
}

# shellcheck disable=SC2016  # $env:는 PowerShell 문법 그대로 찾는다
test_readme_junction_removed_safely() {
    # Windows PowerShell 5.1의 Remove-Item은 비어 있지 않은 정션 안을 재귀 삭제할 수 있다
    assert_file_contains "$README" 'cmd /c rmdir "$env:LOCALAPPDATA\nvim"'
    if grep -qE 'Remove-Item +\$env:LOCALAPPDATA\\nvim' "$README"; then
        fail "README에 정션을 Remove-Item으로 지우는 안내가 남아 있음"
    fi
}

# shellcheck disable=SC2016  # $HOME은 README 문구 그대로 찾는다
test_readme_toolchain_troubleshooting() {
    local phrase
    # apt의 golang-go가 gopls에 너무 오래된 경우, rustup 설치 후 새 셸이 필요한 경우
    for phrase in 'golang-go' 'https://go.dev/dl/' 'gopls' \
        'source "$HOME/.cargo/env"' 'rust_analyzer' '새 셸'; do
        assert_file_contains "$README" "$phrase"
    done
}

test_readme_treesitter_pin_documented() {
    local phrase
    # nvim-treesitter를 master에 고정한 이유와 main 이전 조건
    for phrase in '브랜치에 고정된 이유' 'branch = "master"' \
        'CLI 0.26.1'; do
        assert_file_contains "$README" "$phrase"
    done
    grep -qF 'branch = "master"' "$ROOT/lua/plugins/treesitter.lua" || fail "treesitter.lua에 master 고정이 없음"
}

# shellcheck disable=SC2016  # 마크다운 백틱은 문서 문구 그대로 찾는다
test_wezterm_doc() {
    local phrase
    # WezTerm 멀티플렉서 사용법(키, 백그라운드 유지, 연동, 설정 재적용)과 실제 설정이 함께 있어야 한다
    for phrase in 'prefix` + `"` / `%`' '`prefix` + `d`' '`C-h/j/k/l`' '`prefix` + `C-l`' \
        'default_gui_startup_args' 'OneDark (base16)' '다시 시작'; do
        assert_file_contains "$WEZTERM_DOC" "$phrase"
    done
    assert_file_contains "$README" '(docs/wezterm.md)'
    grep -qF 'config.leader = { key = "a", mods = "CTRL"' "$ROOT/wezterm.lua" || fail "wezterm.lua에 C-a leader가 없음"
    # prefix + 숫자(ActivateTab, 0부터)와 탭 바에 보이는 번호가 같아야 한다
    grep -qF 'config.tab_and_split_indices_are_zero_based = true' "$ROOT/wezterm.lua" ||
        fail "wezterm.lua 탭 바 번호가 0부터가 아님"
    assert_file_contains "$WEZTERM_DOC" '탭 바에 보이는 번호'
}

# shellcheck disable=SC2016  # Lua 코드 문구를 그대로 찾는다
test_wezterm_lua_mux_config() {
    local f="$ROOT/wezterm.lua" phrase
    # 항상 로컬 mux 서버(unix domain)에 붙고, prefix + d로 떼어 낸다
    for phrase in 'config.unix_domains = { { name = "unix" } }' \
        'config.default_gui_startup_args = { "connect", "unix" }' \
        'act.DetachDomain("CurrentPaneDomain")' \
        'IS_NVIM' 'key = "l", mods = "LEADER|CTRL"'; do
        grep -qF -- "$phrase" "$f" || fail "wezterm.lua에 '$phrase'가 없음"
    done
    # 모든 OS 공통: leader와 키가 OS 분기 안(들여쓰기)에 있으면 안 된다
    grep -qE '^config\.leader = \{ key = "a", mods = "CTRL"' "$f" || fail "leader가 OS 분기 밖에 없음"
    grep -qE '^config\.keys = \{' "$f" || fail "keys가 OS 분기 밖에 없음"
}

test_readme_editing_tips() {
    local phrase
    # undo 기록 보존, cp949 파일 감지, ruff 규칙 안내
    for phrase in 'undofile' 'cp949' ':set fileencoding=utf-8' 'extendSelect' ':e ++enc=latin1'; do
        assert_file_contains "$README" "$phrase"
    done
}

# shellcheck disable=SC2016  # 마크다운 백틱은 문서 문구 그대로 찾는다
test_keymaps_doc() {
    local doc="$ROOT/docs/keymaps.md" phrase
    # 전체 키맵은 별도 문서에 두고 README에서 링크한다
    assert_file_contains "$README" '(docs/keymaps.md)'
    for phrase in '`,sn`' '`,sp`' '`]i`' '`[i`' '`]d`' '`,ac`' '`,ff`'; do
        assert_file_contains "$doc" "$phrase"
    done
    # LSP 참조는 nvim 0.11 기본 키 grr을 쓴다
    assert_file_contains "$README" '`grr`'
    assert_file_contains "$doc" '`grr`'
    if grep -qF '`,tc`' "$doc" "$README"; then
        fail "삭제된 ,tc 키가 문서에 남아 있음"
    fi
}

test_plugin_spec_dir_documented() {
    # 플러그인 설정은 lua/plugins/ 디렉터리로 나뉘어 있고 문서도 그 위치를 가리킨다
    [ ! -e "$ROOT/lua/plugins.lua" ] || fail "lua/plugins.lua가 아직 있음"
    if grep -qF 'lua/plugins.lua' "$README" "$ROOT/docs/keymaps.md"; then
        fail "문서에 lua/plugins.lua 참조가 남아 있음"
    fi
    assert_file_contains "$README" '(lua/plugins/)'
    assert_file_contains "$ROOT/docs/keymaps.md" '(../lua/plugins/)'
}

test_readme_plugin_repos_renamed() {
    # mason 계열 저장소는 mason-org, mason-null-ls는 jay-babu로 이전되었다
    if grep -qE 'github.com/(williamboman|jayp0521)/' "$README"; then
        fail "README에 이전 저장소 주소가 남아 있음"
    fi
    # 저장소 주소가 바뀐 플러그인을 다시 받는 방법 안내
    assert_file_contains "$README" 'Origin has changed'
}

test_keymaps_doc_marks_overridden_defaults() {
    local doc="$ROOT/docs/keymaps.md" key
    # nvim 기본 키를 덮어쓰는 텍스트 오브젝트 키는 문서에 그 사실을 적는다
    for key in '\]s' '\]z' '\[i'; do
        grep -E "^\| \`[^|]*${key}" "$doc" | grep -qF '덮어씀' \
            || fail "keymaps.md의 ${key} 줄에 기본 키를 덮어쓴다는 표기가 없음"
    done
}

# shellcheck disable=SC2088  # README 문구의 ~를 그대로 찾는다
test_no_tmux_leftovers() {
    local phrase
    # tmux는 레포에서 빠졌다. 남은 것은 예전 PC를 위한 수동 정리 안내뿐이다
    for phrase in 'tmux.nvim' '(tmux.conf)' 'docs/tmux.md' 'Neovim(+ tmux)' '--with tmux,'; do
        if grep -qF -- "$phrase" "$README" "$ROOT/docs/keymaps.md"; then
            fail "문서에 tmux 흔적 '$phrase'가 남아 있음"
        fi
    done
    assert_file_contains "$README" '~/.tmux.conf'
    assert_file_contains "$README" '~/.tmux/plugins'
}

test_readme_debugger_docs() {
    local phrase
    # 디버그 어댑터 자동 설치(첫 일반 실행 때)와 설치가 끊겼을 때의 복구 안내
    for phrase in 'debugpy' 'codelldb' '디버그 어댑터' ':MasonInstall --force debugpy' '### 디버거가 시작되지 않음' 'mason-nvim-dap' 'LSP 서버, 포매터·린터, 디버그 어댑터는 설치 스크립트 단계가 아니라'; do
        assert_file_contains "$README" "$phrase"
    done
}

test_readme_has_no_legacy_script() {
    [ -f "$README" ] || fail "README.md 없음"
    if grep -qF 'nvim.sh' "$README"; then
        fail "README에 nvim.sh 언급이 남아 있음"
    fi
}

# 마크다운 파일의 상대 링크(http, 앵커 제외)가 실제 파일을 가리키는지 확인한다
check_links() {
    local file="$1" dir link target
    [ -f "$file" ] || fail "파일 없음: $file"
    dir="$(dirname "$file")"
    # while은 파이프 뒤 서브셸에서 돌지만, fail의 exit 1이 파이프라인 종료 코드가 되므로 그대로 전달한다
    grep -oE '\]\([^)]+\)' "$file" | sed 's/^](//; s/)$//' | while IFS= read -r link; do
        case "$link" in
            http://* | https://* | mailto:* | '#'*) continue ;;
        esac
        target="${link%%#*}"
        [ -e "$dir/$target" ] || fail "$file 의 링크가 존재하지 않는 파일을 가리킴: $link"
    done || exit 1
}

test_relative_links_exist() {
    check_links "$README"
    check_links "$WEZTERM_DOC"
    check_links "$ROOT/docs/keymaps.md"
}

test_legacy_files_removed() {
    local f
    for f in nvim.sh vim.md tmuxinator.md tmux.conf docs/tmux.md; do
        [ ! -e "$ROOT/$f" ] || fail "$f 가 아직 있음"
    done
}

test_gitignore_has_lazy_lock() {
    assert_file_contains "$ROOT/.gitignore" 'lazy-lock.json'
}

main() {
    local passed=0 failed=0 name
    for name in $(declare -F | awk '{print $3}' | grep '^test_'); do
        if ( "$name" ); then
            echo "PASS $name"
            passed=$((passed + 1))
        else
            echo "FAIL $name"
            failed=$((failed + 1))
        fi
    done
    echo "결과: 통과 $passed, 실패 $failed"
    [ "$failed" -eq 0 ]
}

main
