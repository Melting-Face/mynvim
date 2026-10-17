#!/usr/bin/env bash
# install.sh 테스트 하네스 (순수 bash, bats 미사용)
# test_* 함수를 자동으로 찾아 각각 서브셸에서 실행하고 통과/실패 수를 보고한다.
# 새 테스트는 이 파일에 test_이름() 함수만 추가하면 된다.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SH="$ROOT/install.sh"

# ---------------------------------------------------------------- 안전 가드
# 모든 테스트는 패키지 설치를 건너뛰고, 임시 HOME에서, XDG_CONFIG_HOME 없이 실행된다.
# 호스트를 건드릴 수 있는 명령은 가짜(FORBIDDEN, exit 99)로 가려 실수가 즉시 실패로 드러나게 한다.
export MYNVIM_SKIP_PACKAGES=1
unset XDG_CONFIG_HOME
FORBIDDEN_BIN="$(mktemp -d)"
for forbidden_cmd in sudo apt-get dnf pacman brew curl; do
    printf '#!/bin/sh\necho "FORBIDDEN %s" >&2\nexit 99\n' "$forbidden_cmd" >"$FORBIDDEN_BIN/$forbidden_cmd"
    chmod +x "$FORBIDDEN_BIN/$forbidden_cmd"
done
export PATH="$FORBIDDEN_BIN:$PATH"

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

test_pacman_first_install_syncs_db() {
    local out
    out="$(MYNVIM_PLATFORM=linux MYNVIM_PKG=pacman "$INSTALL_SH" --with tmux --yes --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    # 첫 설치만 -Syu로 DB를 동기화하고, 이후 설치는 -S
    assert_equals "1" "$(printf '%s\n' "$out" | grep -c 'pacman -Syu ')"
    assert_contains "$out" "pacman -S --noconfirm --needed tmux"
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

# run_install <HOME> <script> [install.sh 인자...] : 격리된 환경에서 install.sh 실행
# 패키지 설치 생략·패키지 관리자·XDG 해제는 호출자가 바꿀 수 없다 (MYNVIM_PLATFORM, PATH는 허용)
run_install() {
    local home="$1" script="$2"
    shift 2
    env -u XDG_CONFIG_HOME HOME="$home" MYNVIM_SKIP_PACKAGES=1 MYNVIM_PKG=apt \
        MYNVIM_PLATFORM="${MYNVIM_PLATFORM:-linux}" \
        /bin/bash "$script" --yes "$@" </dev/null
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
    run_install "$tmp" "$INSTALL_SH" >/dev/null || fail "종료 코드가 0이 아님"
    [ -L "$tmp/.config/nvim" ] || fail "nvim 링크가 없음"
    assert_equals "$ROOT" "$(readlink "$tmp/.config/nvim")"
    rm -rf "$tmp"
}

test_existing_dir_backed_up() {
    local tmp bak
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/.config/nvim"
    echo "mine" >"$tmp/.config/nvim/init.lua"
    run_install "$tmp" "$INSTALL_SH" >/dev/null || fail "종료 코드가 0이 아님"
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
    run_install "$tmp" "$INSTALL_SH" >/dev/null || fail "1회차 실패"
    out="$(run_install "$tmp" "$INSTALL_SH")" || fail "2회차 실패"
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
    run_install "$tmp" "$INSTALL_SH" >/dev/null || fail "종료 코드가 0이 아님"
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
    # shellcheck disable=SC2317,SC2329  # link_path가 호출하는 date를 고정
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
    run_install "$tmp/home" "$repo/install.sh" >/dev/null || fail "종료 코드가 0이 아님"
    assert_equals "$repo" "$(readlink "$tmp/home/.config/nvim")"
    [ -f "$tmp/home/.config/nvim/init.lua" ] || fail "링크를 통해 init.lua가 보이지 않음"
    rm -rf "$tmp"
}

test_wsl_skips_wezterm_even_if_on_path() {
    local tmp out
    tmp="$(mktemp -d)"
    make_fake_wezterm "$tmp/bin"
    mkdir -p "$tmp/home"
    out="$(MYNVIM_PLATFORM=wsl PATH="$tmp/bin:$PATH" run_install "$tmp/home" "$INSTALL_SH")" || fail "종료 코드가 0이 아님"
    [ ! -e "$tmp/home/.wezterm.lua" ] || fail "WSL에서 .wezterm.lua가 생기면 안 됨"
    assert_contains "$out" "Windows"
    rm -rf "$tmp"
}

test_wezterm_linked_when_present() {
    local tmp
    tmp="$(mktemp -d)"
    make_fake_wezterm "$tmp/bin"
    mkdir -p "$tmp/home"
    MYNVIM_PLATFORM=linux PATH="$tmp/bin:$PATH" run_install "$tmp/home" "$INSTALL_SH" >/dev/null || fail "종료 코드가 0이 아님"
    assert_equals "$ROOT/wezterm.lua" "$(readlink "$tmp/home/.wezterm.lua")"
    rm -rf "$tmp"
}

test_tmux_conf_linked_only_when_selected() {
    local tmp
    tmp="$(mktemp -d)"
    run_install "$tmp" "$INSTALL_SH" >/dev/null || fail "종료 코드가 0이 아님"
    [ ! -e "$tmp/.tmux.conf" ] || fail "tmux 미선택인데 링크됨"
    rm -rf "$tmp"
    tmp="$(mktemp -d)"
    run_install "$tmp" "$INSTALL_SH" --with tmux >/dev/null || fail "종료 코드가 0이 아님"
    assert_equals "$ROOT/tmux.conf" "$(readlink "$tmp/.tmux.conf")"
    rm -rf "$tmp"
}

test_clone_into_config_dir_skips() {
    local tmp repo out
    tmp="$(mktemp -d)"
    repo="$tmp/.config/nvim"
    mkdir -p "$repo"
    cp "$ROOT/install.sh" "$ROOT/init.lua" "$ROOT/wezterm.lua" "$ROOT/tmux.conf" "$repo/"
    out="$(run_install "$tmp" "$repo/install.sh")" || fail "종료 코드가 0이 아님"
    assert_contains "$out" "already linked"
    [ ! -L "$repo" ] || fail "링크로 바뀌면 안 됨"
    assert_equals "0" "$(list_baks "$tmp" | wc -l | tr -d ' ')"
    rm -rf "$tmp"
}

test_dry_run_link_changes_nothing() {
    local tmp out
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/.config/nvim"
    out="$(run_install "$tmp" "$INSTALL_SH" --dry-run)" || fail "종료 코드가 0이 아님"
    assert_contains "$out" "+ mv"
    assert_contains "$out" "+ ln -s"
    if [ ! -d "$tmp/.config/nvim" ] || [ -L "$tmp/.config/nvim" ]; then
        fail "dry-run이 변경함"
    fi
    rm -rf "$tmp"
}

test_ensure_nvim_exports_local_bin_on_path() {
    local tmp
    tmp="$(mktemp -d)"
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    HOME="$tmp"
    PKG=apt
    export MYNVIM_NVIM_VERSION=0.9.5 MYNVIM_ARCH=x86_64
    # shellcheck disable=SC2317,SC2329  # ensure_nvim이 호출하는 run을 무력화
    run() { :; }
    ensure_nvim >/dev/null
    case ":$PATH:" in
        *":$tmp/.local/bin:"*) ;;
        *) fail "PATH에 \$HOME/.local/bin이 추가되지 않음: $PATH" ;;
    esac
    rm -rf "$tmp"
}

test_wezterm_missing_prints_note() {
    local tmp out
    tmp="$(mktemp -d)"
    out="$(MYNVIM_ASSUME_MISSING=wezterm run_install "$tmp" "$INSTALL_SH")" || fail "종료 코드가 0이 아님"
    assert_contains "$out" "WezTerm이 감지되지 않아"
    [ ! -e "$tmp/.wezterm.lua" ] || fail ".wezterm.lua가 생기면 안 됨"
    rm -rf "$tmp"
}

# copy_repo <디렉터리> : install.sh가 링크에 쓰는 최소 파일을 복사한다
copy_repo() {
    mkdir -p "$1"
    cp "$ROOT/install.sh" "$ROOT/init.lua" "$ROOT/wezterm.lua" "$ROOT/tmux.conf" "$1/"
}

test_repo_inside_target_aborts_before_mv() {
    local tmp repo out code mode
    tmp="$(mktemp -d)"
    repo="$tmp/.config/nvim/mynvim"
    copy_repo "$repo"
    for mode in --dry-run ""; do
        code=0
        # shellcheck disable=SC2086  # 빈 값이면 인자를 넘기지 않음
        out="$(run_install "$tmp" "$repo/install.sh" $mode 2>&1)" || code=$?
        assert_equals "1" "$code"
        assert_contains "$out" "안에 있습니다"
        assert_not_contains "$out" "+ mv"
    done
    if [ ! -d "$tmp/.config/nvim" ] || [ -L "$tmp/.config/nvim" ]; then
        fail "대상이 바뀌면 안 됨"
    fi
    [ -f "$repo/install.sh" ] || fail "레포가 옮겨지면 안 됨"
    assert_equals "0" "$(list_baks "$tmp" | wc -l | tr -d ' ')"
    rm -rf "$tmp"
}

test_repo_inside_target_physical_path_aborts() {
    local tmp repo code=0
    tmp="$(mktemp -d)"
    # ~/.config가 다른 곳을 가리키는 링크이고, 레포가 그 실제 경로의 nvim 안에 있는 경우
    mkdir -p "$tmp/home" "$tmp/real"
    ln -s "$tmp/real" "$tmp/home/.config"
    repo="$tmp/real/nvim/mynvim"
    copy_repo "$repo"
    run_install "$tmp/home" "$repo/install.sh" >/dev/null 2>&1 || code=$?
    assert_equals "1" "$code"
    [ -f "$repo/install.sh" ] || fail "레포가 옮겨지면 안 됨"
    rm -rf "$tmp"
}

# make_fake_version_cmd <경로> <--version 첫 줄> : 버전만 출력하는 가짜 실행 파일을 만든다
make_fake_version_cmd() {
    mkdir -p "$(dirname "$1")"
    printf '#!/bin/sh\necho "%s"\n' "$2" >"$1"
    chmod +x "$1"
}

# dry_run_linux : 임시 HOME에서 linux/apt 기준 --yes --dry-run 출력 (MYNVIM_ARCH 기본 x86_64)
dry_run_linux() {
    MYNVIM_ARCH="${MYNVIM_ARCH:-x86_64}" MYNVIM_PLATFORM=linux MYNVIM_PKG=apt \
        "$INSTALL_SH" --yes --dry-run </dev/null
}

test_old_node_installs_lts_tarball() {
    local out
    out="$(MYNVIM_NODE_VERSION=12.22.9 dry_run_linux)" || fail "종료 코드가 0이 아님"
    assert_contains "$out" "Node 18 이상이 필요합니다 (현재: 12.22.9)"
    assert_contains "$out" "https://nodejs.org/dist/latest-v22.x"
    assert_contains "$out" "SHASUMS256.txt"
    assert_contains "$out" "sha256sum -c"
    assert_contains "$out" "_ x64 $HOME/.local/opt/node"
    assert_contains "$out" "+ ln -sf $HOME/.local/opt/node/bin/node $HOME/.local/bin/node"
    assert_contains "$out" "+ ln -sf $HOME/.local/opt/node/bin/npm $HOME/.local/bin/npm"
    assert_contains "$out" "+ ln -sf $HOME/.local/opt/node/bin/npx $HOME/.local/bin/npx"
    [ ! -e "$HOME/.local/opt/node" ] || fail "dry-run이 디렉터리를 만들면 안 됨"
}

test_missing_node_arm64_installs_tarball() {
    local out
    out="$(MYNVIM_NODE_VERSION='' MYNVIM_ARCH=aarch64 dry_run_linux)" || fail "종료 코드가 0이 아님"
    assert_contains "$out" "(현재: 없음)"
    assert_contains "$out" "_ arm64 $HOME/.local/opt/node"
}

test_new_node_skips_tarball() {
    local out
    out="$(MYNVIM_NODE_VERSION=20.11.0 dry_run_linux)" || fail "종료 코드가 0이 아님"
    assert_not_contains "$out" "nodejs.org"
    assert_not_contains "$out" "Node 18 이상이 필요합니다"
}

test_local_node_preferred_over_old_path_node() {
    local out
    make_fake_version_cmd "$HOME/.local/bin/node" "v22.11.0"
    out="$(MYNVIM_NODE_VERSION=12.22.9 dry_run_linux)" || fail "종료 코드가 0이 아님"
    assert_not_contains "$out" "nodejs.org"
}

test_brew_old_node_only_warns() {
    local out
    out="$(MYNVIM_NODE_VERSION=12.22.9 MYNVIM_PLATFORM=macos MYNVIM_PKG=brew "$INSTALL_SH" --yes --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_contains "$out" "경고: Node v12.22.9 는 너무 오래되었습니다"
    assert_not_contains "$out" "nodejs.org"
}

test_nvim_tarball_paths_are_positional_args() {
    local out
    out="$(MYNVIM_NVIM_VERSION=0.9.5 dry_run_linux)" || fail "종료 코드가 0이 아님"
    # sh -c 스크립트 문자열에는 경로를 넣지 않고 위치 인자로 넘긴다
    assert_contains "$out" "_ https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz $HOME/.local/opt/nvim"
    # 파이프(curl | tar) 대신 임시 파일로 받은 뒤 푼다
    assert_contains "$out" "curl -fL -o"
    assert_not_contains "$out" "| tar"
    assert_not_contains "$out" "sh -c curl"
    [ ! -e "$HOME/.local/opt/nvim" ] || fail "dry-run이 디렉터리를 만들면 안 됨"
}

test_local_nvim_preferred_over_old_path_nvim() {
    local out
    make_fake_version_cmd "$HOME/.local/bin/nvim" "NVIM v0.11.3"
    out="$(MYNVIM_NVIM_VERSION=0.9.5 dry_run_linux)" || fail "종료 코드가 0이 아님"
    assert_contains "$out" "nvim 0.11.3 확인됨 ($HOME/.local/bin/nvim)"
    assert_not_contains "$out" "nvim-linux-"
}

test_old_local_nvim_still_installs_tarball() {
    local out
    make_fake_version_cmd "$HOME/.local/bin/nvim" "NVIM v0.10.4"
    out="$(MYNVIM_NVIM_VERSION=0.9.5 dry_run_linux)" || fail "종료 코드가 0이 아님"
    assert_contains "$out" "nvim-linux-x86_64"
}

test_shadowed_nvim_warns_about_path_order() {
    local out
    make_fake_version_cmd "$HOME/.local/bin/nvim" "NVIM v0.11.3"
    # PATH에서 오래된 nvim이 ~/.local/bin보다 먼저 잡히는 경우
    make_fake_version_cmd "$HOME/oldbin/nvim" "NVIM v0.9.5"
    out="$(PATH="$HOME/oldbin:$PATH:$HOME/.local/bin" dry_run_linux)" || fail "종료 코드가 0이 아님"
    assert_contains "$out" "$HOME/oldbin/nvim"
    assert_contains "$out" "PATH 맨 앞에 두세요"
    assert_contains "$out" "export PATH=\"\$HOME/.local/bin:\$PATH\""
}

test_local_bin_first_no_path_warning() {
    local out
    make_fake_version_cmd "$HOME/.local/bin/nvim" "NVIM v0.11.3"
    make_fake_version_cmd "$HOME/oldbin/nvim" "NVIM v0.9.5"
    out="$(PATH="$HOME/.local/bin:$HOME/oldbin:$PATH" MYNVIM_NODE_VERSION=20.11.0 dry_run_linux)" \
        || fail "종료 코드가 0이 아님"
    assert_not_contains "$out" "PATH 맨 앞에"
}

test_dry_run_old_nvim_has_tarball_then_lazy_sync() {
    local out
    out="$(MYNVIM_SKIP_PACKAGES=0 MYNVIM_NVIM_VERSION=0.9.5 MYNVIM_PLATFORM=linux MYNVIM_PKG=apt "$INSTALL_SH" --yes --dry-run </dev/null)" \
        || fail "종료 코드가 0이 아님"
    assert_contains "$out" "nvim-linux-"
    assert_contains "$out" "+ nvim --headless +Lazy! sync +qa"
}

# ---------------------------------------------------------------- 사전 점검 / tarball / 대화형

test_repo_inside_target_preflight_before_packages() {
    local tmp repo out code=0
    tmp="$(mktemp -d)"
    repo="$tmp/.config/nvim/mynvim"
    copy_repo "$repo"
    # dry-run은 MYNVIM_SKIP_PACKAGES를 무시하므로, 사전 점검이 없으면 패키지 단계가 출력된다
    out="$(MYNVIM_PLATFORM=linux run_install "$tmp" "$repo/install.sh" --dry-run 2>&1)" || code=$?
    assert_equals "1" "$code"
    assert_contains "$out" "안에 있습니다"
    assert_not_contains "$out" "apt-get"
    assert_not_contains "$out" "+ "
    rm -rf "$tmp"
}

test_repo_inside_target_preflight_brew() {
    local tmp repo out code=0
    tmp="$(mktemp -d)"
    repo="$tmp/.config/nvim/mynvim"
    copy_repo "$repo"
    out="$(env -u XDG_CONFIG_HOME HOME="$tmp" MYNVIM_PLATFORM=macos MYNVIM_PKG=brew \
        /bin/bash "$repo/install.sh" --yes --dry-run 2>&1 </dev/null)" || code=$?
    assert_equals "1" "$code"
    assert_contains "$out" "안에 있습니다"
    assert_not_contains "$out" "+ brew"
    rm -rf "$tmp"
}

# make_fake_curl <디렉터리> : -o 지정 시 FAKE_TARBALL을 복사하고, SHASUMS256.txt 요청에는 FAKE_SHASUMS를 출력한다
# FAKE_TARBALL이 없으면 다운로드 실패(exit 22)를 흉내 낸다
make_fake_curl() {
    mkdir -p "$1"
    cat >"$1/curl" <<'FAKE'
#!/bin/sh
out=""
url=""
while [ $# -gt 0 ]; do
    case "$1" in
        -o) out="$2"; shift 2 ;;
        -*) shift ;;
        *) url="$1"; shift ;;
    esac
done
case "$url" in
    *SHASUMS256.txt)
        [ -n "${FAKE_SHASUMS:-}" ] || exit 22
        if [ -n "$out" ]; then
            printf '%s\n' "$FAKE_SHASUMS" >"$out"
        else
            printf '%s\n' "$FAKE_SHASUMS"
        fi
        exit 0
        ;;
esac
if [ -n "${FAKE_TARBALL:-}" ] && [ -n "$out" ]; then
    cp "$FAKE_TARBALL" "$out"
    exit 0
fi
echo "curl: (22) fake failure: $url" >&2
exit 22
FAKE
    chmod +x "$1/curl"
    # mktemp -d가 만든 임시 디렉터리를 <디렉터리>/../t 아래에 두고 경로를 t.log에 남긴다
    # (macOS mktemp는 환경에 따라 TMPDIR을 따르지 않으므로 가짜로 고정한다)
    cat >"$1/mktemp" <<FAKE
#!/bin/sh
d="$1/../t/tmp.\$\$"
mkdir -p "\$d"
echo "\$d" >>"$1/../t.log"
echo "\$d"
FAKE
    chmod +x "$1/mktemp"
}

# assert_temp_cleaned <make_fake_curl에 준 디렉터리> : 임시 디렉터리가 만들어졌다가 지워졌는지 확인한다
assert_temp_cleaned() {
    [ -s "$1/../t.log" ] || fail "임시 디렉터리가 만들어지지 않음"
    [ -z "$(ls -A "$1/../t" 2>/dev/null)" ] || fail "임시 디렉터리가 남아 있음: $(ls -A "$1/../t")"
}

test_nvim_tarball_download_failure_cleans_temp() {
    local tmp out code=0
    tmp="$(mktemp -d)"
    make_fake_curl "$tmp/bin"
    mkdir -p "$tmp/dest"
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    out="$(PATH="$tmp/bin:$PATH" sh -c "$(nvim_tarball_script)" _ \
        "https://example.invalid/nvim.tar.gz" "$tmp/dest" 2>&1)" || code=$?
    [ "$code" -ne 0 ] || fail "다운로드 실패인데 종료 코드가 0"
    assert_contains "$out" "다운로드 실패"
    assert_temp_cleaned "$tmp/bin"
    rm -rf "$tmp"
}

test_nvim_tarball_success_extracts_and_cleans_temp() {
    local tmp code=0
    tmp="$(mktemp -d)"
    make_fake_curl "$tmp/bin"
    mkdir -p "$tmp/dest" "$tmp/src/nvim-linux-x86_64/bin"
    echo "fake" >"$tmp/src/nvim-linux-x86_64/bin/nvim"
    tar -czf "$tmp/nvim.tar.gz" -C "$tmp/src" nvim-linux-x86_64
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    PATH="$tmp/bin:$PATH" FAKE_TARBALL="$tmp/nvim.tar.gz" \
        sh -c "$(nvim_tarball_script)" _ "https://example.invalid/nvim.tar.gz" "$tmp/dest" >/dev/null 2>&1 || code=$?
    assert_equals "0" "$code"
    [ -f "$tmp/dest/bin/nvim" ] || fail "tarball이 풀리지 않음"
    assert_temp_cleaned "$tmp/bin"
    rm -rf "$tmp"
}

test_node_tarball_download_failure_cleans_temp() {
    local tmp code=0
    tmp="$(mktemp -d)"
    make_fake_curl "$tmp/bin"
    mkdir -p "$tmp/dest"
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    # SHASUMS256.txt는 받지만 tarball 다운로드는 실패하는 경우
    PATH="$tmp/bin:$PATH" \
        FAKE_SHASUMS="0000  node-v22.0.0-linux-x64.tar.xz" \
        sh -c "$(node_tarball_script)" _ x64 "$tmp/dest" >/dev/null 2>&1 || code=$?
    [ "$code" -ne 0 ] || fail "다운로드 실패인데 종료 코드가 0"
    assert_temp_cleaned "$tmp/bin"
    rm -rf "$tmp"
}

test_node_tarball_success_extracts_and_cleans_temp() {
    local tmp code=0 file="node-v22.0.0-linux-x64.tar.xz" sum
    tmp="$(mktemp -d)"
    make_fake_curl "$tmp/bin"
    mkdir -p "$tmp/dest" "$tmp/src/node-v22.0.0-linux-x64/bin"
    echo "fake" >"$tmp/src/node-v22.0.0-linux-x64/bin/node"
    tar -cJf "$tmp/$file" -C "$tmp/src" node-v22.0.0-linux-x64
    sum="$(cd "$tmp" && sha256sum "$file" | cut -d' ' -f1)"
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    PATH="$tmp/bin:$PATH" FAKE_TARBALL="$tmp/$file" FAKE_SHASUMS="$sum  $file" \
        sh -c "$(node_tarball_script)" _ x64 "$tmp/dest" >/dev/null 2>&1 || code=$?
    assert_equals "0" "$code"
    [ -f "$tmp/dest/bin/node" ] || fail "tarball이 풀리지 않음"
    assert_temp_cleaned "$tmp/bin"
    rm -rf "$tmp"
}

test_choose_components_eof_means_no() {
    local out
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    WITH=""
    ASSUME_YES=0
    # shellcheck disable=SC2317,SC2329  # TTY 확인을 대화형으로 고정
    is_interactive() { return 0; }
    # set -e 아래에서 EOF(입력 없음)여도 조용히 종료되지 않고 N으로 처리되어야 한다
    out="$(
        set -euo pipefail
        choose_components </dev/null 2>/dev/null
        echo "rc=$? WITH=[$WITH]"
    )"
    assert_equals "rc=0 WITH=[]" "$out"
}

test_choose_components_reads_answers() {
    local out
    # shellcheck source=/dev/null
    source "$INSTALL_SH"
    WITH=""
    ASSUME_YES=0
    # shellcheck disable=SC2317,SC2329
    is_interactive() { return 0; }
    out="$(
        set -euo pipefail
        # 파이프는 서브셸에서 돌아 WITH가 전달되지 않으므로 리다이렉트로 입력한다 (마지막 두 질문은 EOF)
        choose_components 2>/dev/null <<<"$(printf 'y\nn\nY')"
        echo "WITH=[$WITH]"
    )"
    assert_equals "WITH=[tmux rust]" "$out"
}

# ---------------------------------------------------------------- 실행기

main() {
    local passed=0 failed=0 name test_home
    local names
    names="$(declare -F | awk '{print $3}' | grep '^test_' || true)"
    for name in $names; do
        test_home="$(mktemp -d)"
        if ( export HOME="$test_home"; "$name" ); then
            echo "PASS $name"
            passed=$((passed + 1))
        else
            echo "FAIL $name"
            failed=$((failed + 1))
        fi
        rm -rf "$test_home"
    done
    echo "결과: 통과 $passed, 실패 $failed"
    [ "$failed" -eq 0 ]
}

main
