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

test_core_apt_has_build_essential() {
    local out
    out="$(MYNVIM_PLATFORM=linux MYNVIM_PKG=apt "$INSTALL_SH" --yes --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_contains "$out" "build-essential"
    assert_not_contains "$out" "tmux"
}

test_with_tmux_installs_tmux_and_tpm() {
    local out home
    home="$(mktemp -d)"
    out="$(HOME="$home" MYNVIM_PLATFORM=linux MYNVIM_PKG=apt "$INSTALL_SH" --with tmux --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_contains "$out" "apt-get install -y tmux"
    assert_contains "$out" "tmux-plugins/tpm"
}

test_rust_uses_rustup_noninteractive() {
    local out
    out="$(MYNVIM_ASSUME_MISSING=rustup MYNVIM_PLATFORM=linux MYNVIM_PKG=apt "$INSTALL_SH" --with rust --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_contains "$out" "sh.rustup.rs"
    assert_contains "$out" "-y"
}

test_brew_core_has_gnu_sed() {
    local out
    out="$(MYNVIM_PLATFORM=macos MYNVIM_PKG=brew "$INSTALL_SH" --yes --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_contains "$out" "gnu-sed"
}

test_wsl_skips_clipboard_pkg() {
    local out
    out="$(MYNVIM_PLATFORM=wsl MYNVIM_PKG=apt "$INSTALL_SH" --yes --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_not_contains "$out" "xclip"
    assert_not_contains "$out" "wl-clipboard"
}

test_old_nvim_triggers_tarball() {
    local out
    out="$(MYNVIM_NVIM_VERSION=0.9.5 MYNVIM_ARCH=x86_64 MYNVIM_PLATFORM=linux MYNVIM_PKG=apt "$INSTALL_SH" --yes --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_contains "$out" "nvim-linux-x86_64"
}

test_new_nvim_skips_tarball() {
    local out
    out="$(MYNVIM_NVIM_VERSION=0.11.2 MYNVIM_PLATFORM=linux MYNVIM_PKG=apt "$INSTALL_SH" --yes --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_not_contains "$out" "nvim-linux-"
}

test_arm64_tarball_name() {
    local out
    out="$(MYNVIM_NVIM_VERSION='' MYNVIM_ARCH=aarch64 MYNVIM_PLATFORM=linux MYNVIM_PKG=apt "$INSTALL_SH" --yes --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_contains "$out" "nvim-linux-arm64"
}

test_brew_missing_exits_with_guide() {
    local out code=0
    out="$(PATH=/usr/bin:/bin MYNVIM_PLATFORM=macos /bin/bash "$INSTALL_SH" --yes --dry-run 2>&1 </dev/null)" || code=$?
    assert_equals "1" "$code"
    assert_contains "$out" "brew.sh"
}

test_java_brew_uses_cask() {
    local out
    out="$(MYNVIM_PLATFORM=macos MYNVIM_PKG=brew "$INSTALL_SH" --with java --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_contains "$out" "brew install --cask temurin@21"
}

test_nvim_version_ok_compare() {
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    nvim_version_ok 0.11.0 || fail "0.11.0은 통과해야 함"
    nvim_version_ok 0.12.1 || fail "0.12.1은 통과해야 함"
    nvim_version_ok 1.0.0 || fail "1.0.0은 통과해야 함"
    ! nvim_version_ok 0.9.5 || fail "0.9.5는 실패해야 함"
    ! nvim_version_ok 0.10.4 || fail "0.10.4는 실패해야 함"
    ! nvim_version_ok "" || fail "빈 값은 실패해야 함"
}

# ---------------------------------------------------------------- 링크 테스트
# 실제 링크를 만들므로 항상 임시 HOME에서, XDG_CONFIG_HOME 없이, 패키지 단계 생략으로 실행한다.

# run_install <HOME> [env 인자...] -- [install.sh 인자...] : 격리된 환경에서 install.sh 실행
run_install() {
    local home="$1" script="$INSTALL_SH"
    shift
    env -u XDG_CONFIG_HOME HOME="$home" MYNVIM_SKIP_PACKAGES=1 MYNVIM_PKG=apt MYNVIM_PLATFORM=linux \
        "$@" /bin/bash "$script" --yes </dev/null
}

# list_baks <HOME> : nvim 백업 항목 경로를 한 줄씩 출력한다
list_baks() {
    find "$1/.config" -maxdepth 1 -name 'nvim.bak.*'
}

# make_fake_wezterm <디렉터리> : PATH에 둘 가짜 wezterm 실행 파일을 만든다
make_fake_wezterm() {
    mkdir -p "$1"
    printf '#!/bin/sh\nexit 0\n' >"$1/wezterm"
    chmod +x "$1/wezterm"
}

test_link_creates_symlink() {
    local tmp
    tmp="$(mktemp -d)"
    run_install "$tmp" >/dev/null || fail "종료 코드가 0이 아님"
    [ -L "$tmp/.config/nvim" ] || fail "nvim 링크가 없음"
    assert_equals "$ROOT" "$(readlink "$tmp/.config/nvim")"
    rm -rf "$tmp"
}

test_existing_dir_backed_up() {
    local tmp bak
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/.config/nvim"
    echo "mine" >"$tmp/.config/nvim/init.lua"
    run_install "$tmp" >/dev/null || fail "종료 코드가 0이 아님"
    [ -L "$tmp/.config/nvim" ] || fail "nvim 링크가 없음"
    bak="$(list_baks "$tmp" | head -n 1)"
    [ -n "$bak" ] || fail "백업이 없음"
    assert_equals "mine" "$(cat "$bak/init.lua")"
    rm -rf "$tmp"
}

test_rerun_no_new_backup() {
    local tmp out count
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/.config/nvim"
    run_install "$tmp" >/dev/null || fail "1회차 실패"
    out="$(run_install "$tmp")" || fail "2회차 실패"
    assert_contains "$out" "already linked"
    count="$(list_baks "$tmp" | wc -l | tr -d ' ')"
    assert_equals "1" "$count"
    rm -rf "$tmp"
}

test_dangling_symlink_backed_up() {
    local tmp bak
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/.config"
    ln -s "$tmp/nowhere" "$tmp/.config/nvim"
    run_install "$tmp" >/dev/null || fail "종료 코드가 0이 아님"
    assert_equals "$ROOT" "$(readlink "$tmp/.config/nvim")"
    bak="$(list_baks "$tmp" | head -n 1)"
    [ -L "$bak" ] || fail "깨진 링크가 백업되지 않음"
    assert_equals "$tmp/nowhere" "$(readlink "$bak")"
    [ ! -e "$tmp/nowhere" ] || fail "원래 링크 대상이 생기면 안 됨"
    rm -rf "$tmp"
}

test_backup_name_collision_never_overwrites() {
    local tmp
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/.config/nvim"
    echo "mine" >"$tmp/.config/nvim/init.lua"
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    # shellcheck disable=SC2329  # link_path가 호출하는 date를 고정
    date() { echo "20260101-000000"; }
    mkdir -p "$tmp/.config/nvim.bak.20260101-000000"
    echo "old" >"$tmp/.config/nvim.bak.20260101-000000/keep"
    link_path "$ROOT" "$tmp/.config/nvim" >/dev/null
    assert_equals "old" "$(cat "$tmp/.config/nvim.bak.20260101-000000/keep")"
    assert_equals "mine" "$(cat "$tmp/.config/nvim.bak.20260101-000000-1/init.lua")"
    rm -rf "$tmp"
}

test_repo_path_with_spaces() {
    local tmp repo
    tmp="$(mktemp -d)"
    repo="$tmp/my repos/mynvim"
    mkdir -p "$repo"
    cp "$ROOT/install.sh" "$ROOT/init.lua" "$ROOT/wezterm.lua" "$ROOT/tmux.conf" "$repo/"
    mkdir -p "$tmp/home"
    env -u XDG_CONFIG_HOME HOME="$tmp/home" MYNVIM_SKIP_PACKAGES=1 MYNVIM_PKG=apt MYNVIM_PLATFORM=linux \
        /bin/bash "$repo/install.sh" --yes </dev/null >/dev/null || fail "종료 코드가 0이 아님"
    assert_equals "$repo" "$(readlink "$tmp/home/.config/nvim")"
    [ -f "$tmp/home/.config/nvim/init.lua" ] || fail "링크를 통해 init.lua가 보이지 않음"
    rm -rf "$tmp"
}

test_wsl_skips_wezterm_even_if_on_path() {
    local tmp out
    tmp="$(mktemp -d)"
    make_fake_wezterm "$tmp/bin"
    mkdir -p "$tmp/home"
    out="$(run_install "$tmp/home" MYNVIM_PLATFORM=wsl PATH="$tmp/bin:$PATH")" || fail "종료 코드가 0이 아님"
    [ ! -e "$tmp/home/.wezterm.lua" ] || fail "WSL에서 .wezterm.lua가 생기면 안 됨"
    assert_contains "$out" "Windows"
    rm -rf "$tmp"
}

test_wezterm_linked_when_present() {
    local tmp
    tmp="$(mktemp -d)"
    make_fake_wezterm "$tmp/bin"
    mkdir -p "$tmp/home"
    run_install "$tmp/home" MYNVIM_PLATFORM=linux PATH="$tmp/bin:$PATH" >/dev/null || fail "종료 코드가 0이 아님"
    assert_equals "$ROOT/wezterm.lua" "$(readlink "$tmp/home/.wezterm.lua")"
    rm -rf "$tmp"
}

test_tmux_conf_linked_only_when_selected() {
    local tmp
    tmp="$(mktemp -d)"
    run_install "$tmp" >/dev/null || fail "종료 코드가 0이 아님"
    [ ! -e "$tmp/.tmux.conf" ] || fail "tmux 미선택인데 링크됨"
    rm -rf "$tmp"
    tmp="$(mktemp -d)"
    env -u XDG_CONFIG_HOME HOME="$tmp" MYNVIM_SKIP_PACKAGES=1 MYNVIM_PKG=apt MYNVIM_PLATFORM=linux \
        /bin/bash "$INSTALL_SH" --with tmux </dev/null >/dev/null || fail "종료 코드가 0이 아님"
    assert_equals "$ROOT/tmux.conf" "$(readlink "$tmp/.tmux.conf")"
    rm -rf "$tmp"
}

test_clone_into_config_dir_skips() {
    local tmp repo out
    tmp="$(mktemp -d)"
    repo="$tmp/.config/nvim"
    mkdir -p "$repo"
    cp "$ROOT/install.sh" "$ROOT/init.lua" "$ROOT/wezterm.lua" "$ROOT/tmux.conf" "$repo/"
    out="$(env -u XDG_CONFIG_HOME HOME="$tmp" MYNVIM_SKIP_PACKAGES=1 MYNVIM_PKG=apt MYNVIM_PLATFORM=linux \
        /bin/bash "$repo/install.sh" --yes </dev/null)" || fail "종료 코드가 0이 아님"
    assert_contains "$out" "already linked"
    [ ! -L "$repo" ] || fail "링크로 바뀌면 안 됨"
    assert_equals "0" "$(list_baks "$tmp" | wc -l | tr -d ' ')"
    rm -rf "$tmp"
}

test_dry_run_link_changes_nothing() {
    local tmp out
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/.config/nvim"
    out="$(env -u XDG_CONFIG_HOME HOME="$tmp" MYNVIM_SKIP_PACKAGES=1 MYNVIM_PKG=apt MYNVIM_PLATFORM=linux \
        /bin/bash "$INSTALL_SH" --yes --dry-run </dev/null)" || fail "종료 코드가 0이 아님"
    assert_contains "$out" "+ mv"
    assert_contains "$out" "+ ln -s"
    [ -d "$tmp/.config/nvim" ] && [ ! -L "$tmp/.config/nvim" ] || fail "dry-run이 변경함"
    rm -rf "$tmp"
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
