#!/usr/bin/env bash
# install.sh 테스트 하네스 (순수 bash, bats 미사용)
# test_* 함수를 자동으로 찾아 각각 서브셸에서 실행하고 통과/실패 수를 보고한다.
# 새 테스트는 이 파일에 test_이름() 함수만 추가하면 된다.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SH="$ROOT/install.sh"

# 실패 시 서브셸(테스트 하나)을 즉시 종료한다
fail() {
    echo "    FAIL: $*" >&2
    exit 1
}

# assert_contains <출력> <부분문자열>
assert_contains() {
    case "$1" in
        *"$2"*) ;;
        *) fail "출력에 '$2'가 없음: $1" ;;
    esac
}

# assert_not_contains <출력> <부분문자열>
assert_not_contains() {
    case "$1" in
        *"$2"*) fail "출력에 '$2'가 있으면 안 됨: $1" ;;
    esac
}

# assert_exit <기대 코드> <명령...> : 명령을 실행해 종료 코드를 비교한다
assert_exit() {
    local expected="$1" actual=0
    shift
    "$@" >/dev/null 2>&1 || actual=$?
    [ "$actual" -eq "$expected" ] || fail "종료 코드 기대 $expected, 실제 $actual: $*"
}

# assert_equals <기대값> <실제값>
assert_equals() {
    [ "$1" = "$2" ] || fail "기대 '$1', 실제 '$2'"
}

# ---------------------------------------------------------------- 테스트

test_unknown_component_exits_2() {
    assert_exit 2 env MYNVIM_PLATFORM=linux MYNVIM_PKG=apt "$INSTALL_SH" --with foo --dry-run
}

test_unknown_flag_exits_2() {
    assert_exit 2 env MYNVIM_PLATFORM=linux MYNVIM_PKG=apt "$INSTALL_SH" --bogus --dry-run
}

test_help_exits_0() {
    local out
    out="$("$INSTALL_SH" --help)" || fail "--help 종료 코드가 0이 아님"
    assert_contains "$out" "--with"
}

test_all_expands_to_five() {
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    parse_args --all
    assert_equals "tmux go rust java lua" "$WITH"
}

test_with_list_parsed() {
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    parse_args --with tmux,rust
    assert_equals "tmux rust" "$WITH"
}

test_with_and_all_union_dedup() {
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    parse_args --with rust,rust --all
    assert_equals "tmux go rust java lua" "$WITH"
}

test_flags_set_globals() {
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    parse_args --yes --dry-run
    assert_equals "1" "$ASSUME_YES"
    assert_equals "1" "$DRY_RUN"
}

test_non_tty_no_args_core_only() {
    local out
    out="$(MYNVIM_PLATFORM=linux MYNVIM_PKG=apt "$INSTALL_SH" --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_not_contains "$out" "tmux"
    assert_not_contains "$out" "rustup"
}

test_main_summary_with_components() {
    local out
    out="$(MYNVIM_PLATFORM=linux MYNVIM_PKG=apt "$INSTALL_SH" --with tmux --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_contains "$out" "tmux"
    assert_contains "$out" "apt"
}

test_platform_override() {
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    MYNVIM_PLATFORM=wsl MYNVIM_PKG=apt detect_platform
    assert_equals "wsl" "$PLATFORM"
    assert_equals "apt" "$PKG"
}

test_detect_wsl_from_proc_version() {
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    MYNVIM_UNAME=Linux MYNVIM_PKG=apt \
        MYNVIM_PROC_VERSION="Linux version 5.15 (microsoft-standard-WSL2)" detect_platform
    assert_equals "wsl" "$PLATFORM"
}

test_detect_linux_without_microsoft() {
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    MYNVIM_UNAME=Linux MYNVIM_PKG=dnf MYNVIM_PROC_VERSION="Linux version 6.1 (debian)" detect_platform
    assert_equals "linux" "$PLATFORM"
    assert_equals "dnf" "$PKG"
}

test_detect_macos_uses_brew() {
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    MYNVIM_UNAME=Darwin detect_platform
    assert_equals "macos" "$PLATFORM"
    assert_equals "brew" "$PKG"
}

test_run_dry_run_prints_command() {
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    DRY_RUN=1
    local out
    out="$(run printf hello)"
    assert_equals "+ printf hello" "$out"
}

test_run_executes_when_not_dry_run() {
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    DRY_RUN=0
    local out
    out="$(run printf hello)"
    assert_equals "hello" "$out"
}

# ---------------------------------------------------------------- 실행기

main() {
    local passed=0 failed=0 name
    local names
    names="$(declare -F | awk '{print $3}' | grep '^test_' || true)"
    for name in $names; do
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
