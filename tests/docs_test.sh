#!/usr/bin/env bash
# 문서 검증 테스트 (순수 bash, bash 3.2 호환)
# README 구조, 필수 문구, 상대 링크, 삭제된 파일, .gitignore를 확인한다.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README="$ROOT/README.md"
TMUX_DOC="$ROOT/docs/tmux.md"

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
    for link in $(grep -oE '\]\([^)]+\)' "$file" | sed 's/^](//; s/)$//'); do
        case "$link" in
            http://* | https://* | mailto:* | '#'*) continue ;;
        esac
        target="${link%%#*}"
        [ -e "$dir/$target" ] || fail "$file 의 링크가 존재하지 않는 파일을 가리킴: $link"
    done
}

test_relative_links_exist() {
    check_links "$README"
    check_links "$TMUX_DOC"
}

test_legacy_files_removed() {
    local f
    for f in nvim.sh vim.md tmuxinator.md; do
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
