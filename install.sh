#!/usr/bin/env bash
# mynvim 설치 스크립트 (macOS / Linux / WSL)
# 사용법: ./install.sh [--with <쉼표 목록>] [--all] [--yes] [--dry-run] [--help]
# macOS 기본 bash 3.2에서 동작해야 하므로 연관 배열, mapfile, ${var,,}를 쓰지 않는다.

# shellcheck disable=SC2034  # Task 3, 4에서 사용
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALL_COMPONENTS="tmux go rust java lua"

WITH=""
ASSUME_YES=0
DRY_RUN=0
PLATFORM=""
PKG=""

usage() {
    cat <<USAGE
사용법: install.sh [옵션]

옵션:
  --with <목록>  선택 항목을 쉼표로 지정 (tmux,go,rust,java,lua)
  --all          모든 선택 항목 설치
  --yes          대화형 질문 없이 진행 (선택 항목 미지정 시 필수만 설치)
  --dry-run      실행할 명령만 출력하고 아무것도 변경하지 않음
  --help         이 도움말 출력
USAGE
}

# 오류 메시지를 stderr로 출력한다
err() {
    echo "install.sh: $*" >&2
}

# 유효한 선택 항목 이름인지 확인한다
is_component() {
    local c
    for c in $ALL_COMPONENTS; do
        [ "$c" = "$1" ] && return 0
    done
    return 1
}

# WITH에 항목을 중복 없이 추가한다
add_component() {
    case " $WITH " in
        *" $1 "*) ;;
        *) WITH="${WITH:+$WITH }$1" ;;
    esac
}

# WITH를 ALL_COMPONENTS의 정해진 순서로 정렬한다
normalize_with() {
    local c sorted=""
    for c in $ALL_COMPONENTS; do
        case " $WITH " in
            *" $c "*) sorted="${sorted:+$sorted }$c" ;;
        esac
    done
    WITH="$sorted"
}

parse_args() {
    local list item
    while [ $# -gt 0 ]; do
        case "$1" in
            --with)
                if [ $# -lt 2 ]; then
                    err "--with에는 값이 필요합니다"
                    exit 2
                fi
                list="${2//,/ }"
                for item in $list; do
                    if ! is_component "$item"; then
                        err "알 수 없는 항목: $item (사용 가능: $ALL_COMPONENTS)"
                        exit 2
                    fi
                    add_component "$item"
                done
                shift 2
                ;;
            --all)
                for item in $ALL_COMPONENTS; do
                    add_component "$item"
                done
                shift
                ;;
            --yes)
                ASSUME_YES=1
                shift
                ;;
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            --help | -h)
                usage
                exit 0
                ;;
            *)
                err "알 수 없는 옵션: $1"
                usage >&2
                exit 2
                ;;
        esac
    done
    normalize_with
}

detect_platform() {
    local uname_s proc_version

    if [ -n "${MYNVIM_PLATFORM:-}" ]; then
        PLATFORM="$MYNVIM_PLATFORM"
    else
        uname_s="${MYNVIM_UNAME:-$(uname -s)}"
        if [ "$uname_s" = "Darwin" ]; then
            PLATFORM="macos"
        else
            proc_version="${MYNVIM_PROC_VERSION:-}"
            if [ -z "$proc_version" ] && [ -r /proc/version ]; then
                proc_version="$(cat /proc/version)"
            fi
            case "$proc_version" in
                *[Mm]icrosoft*) PLATFORM="wsl" ;;
                *) PLATFORM="linux" ;;
            esac
        fi
    fi

    if [ -n "${MYNVIM_PKG:-}" ]; then
        PKG="$MYNVIM_PKG"
    elif [ "$PLATFORM" = "macos" ]; then
        PKG="brew"
    elif command -v apt-get >/dev/null 2>&1; then
        PKG="apt"
    elif command -v dnf >/dev/null 2>&1; then
        PKG="dnf"
    elif command -v pacman >/dev/null 2>&1; then
        PKG="pacman"
    else
        err "지원하는 패키지 관리자(apt, dnf, pacman)를 찾을 수 없습니다"
        exit 1
    fi
}

# 선택 항목이 없고 대화형(TTY)일 때만 항목별로 y/N을 묻는다
choose_components() {
    local c answer
    if [ -n "$WITH" ] || [ "$ASSUME_YES" -eq 1 ] || [ ! -t 0 ]; then
        return 0
    fi
    for c in $ALL_COMPONENTS; do
        read -r -p "$c 을(를) 설치할까요? [y/N] " answer
        case "$answer" in
            y | Y | yes | YES) add_component "$c" ;;
        esac
    done
    normalize_with
}

# DRY_RUN=1이면 명령만 출력하고, 아니면 실행한다
run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "+ $*"
    else
        "$@"
    fi
}

# 사용 가능한 명령인지 확인한다 (MYNVIM_ASSUME_MISSING에 적힌 이름은 없는 것으로 취급: 테스트용)
has_cmd() {
    case " ${MYNVIM_ASSUME_MISSING:-} " in
        *" $1 "*) return 1 ;;
    esac
    command -v "$1" >/dev/null 2>&1
}

# 루트가 아니면 sudo를 붙인다 (컨테이너 등 루트 환경에서는 비움)
SUDO=""
APT_UPDATED=0
init_sudo() {
    SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi
}

# 현재 PKG 기준 패키지 이름을 공백 구분으로 출력한다 (없으면 빈 문자열)
pkg_names() {
    case "$1" in
        core)
            case "$PKG" in
                brew) echo "git ripgrep node python gnu-sed" ;;
                apt) echo "git ripgrep nodejs npm python3 python3-pip python3-venv build-essential curl unzip $(clipboard_pkg)" ;;
                dnf) echo "git ripgrep nodejs python3 python3-pip gcc make curl unzip $(clipboard_pkg)" ;;
                pacman) echo "git ripgrep nodejs npm python python-pip base-devel curl unzip $(clipboard_pkg)" ;;
            esac
            ;;
        tmux) echo "tmux" ;;
        go)
            case "$PKG" in
                apt) echo "golang-go" ;;
                dnf) echo "golang" ;;
                *) echo "go" ;;
            esac
            ;;
        rust) echo "" ;;
        java)
            case "$PKG" in
                brew) echo "temurin@21" ;;
                apt) echo "openjdk-21-jdk" ;;
                dnf) echo "java-21-openjdk-devel" ;;
                pacman) echo "jdk21-openjdk" ;;
            esac
            ;;
        lua)
            case "$PKG" in
                apt) echo "lua5.4" ;;
                *) echo "lua" ;;
            esac
            ;;
    esac
}

# 리눅스 클립보드 패키지 이름 (WSL은 win32yank를 쓰므로 빈 문자열)
clipboard_pkg() {
    if [ "$PLATFORM" = "linux" ]; then
        if [ -n "${WAYLAND_DISPLAY:-}" ]; then
            echo "wl-clipboard"
        else
            echo "xclip"
        fi
    fi
}

# 패키지 관리자로 패키지를 설치한다
pkg_install() {
    [ $# -gt 0 ] || return 0
    case "$PKG" in
        brew) run brew install "$@" ;;
        apt)
            if [ "$APT_UPDATED" -eq 0 ]; then
                run $SUDO apt-get update
                APT_UPDATED=1
            fi
            run $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
            ;;
        dnf) run $SUDO dnf install -y "$@" ;;
        pacman) run $SUDO pacman -S --noconfirm --needed "$@" ;;
    esac
}

# brew가 없으면 안내 후 종료한다
require_brew() {
    if ! has_cmd brew; then
        err "Homebrew가 필요합니다. https://brew.sh 를 참고해 먼저 설치하세요"
        exit 1
    fi
}

install_core() {
    local pkgs
    if [ "$PKG" = "brew" ]; then
        require_brew
        if [ "$PLATFORM" = "macos" ] && ! xcode-select -p >/dev/null 2>&1; then
            echo "C 컴파일러가 필요합니다. 다음을 실행하세요: xcode-select --install"
        fi
    else
        init_sudo
    fi
    if [ "$PLATFORM" = "wsl" ] && ! has_cmd win32yank.exe; then
        echo "WSL 클립보드: Windows 쪽에 win32yank.exe를 설치하세요 (winget install equalsraf.win32yank)"
    fi
    pkgs="$(pkg_names core)"
    # shellcheck disable=SC2086  # 공백 구분 목록을 의도적으로 분리
    pkg_install $pkgs
    warn_old_node
}

# Node 18 미만이면 경고만 출력한다
warn_old_node() {
    local v major
    has_cmd node || return 0
    v="$(node -v 2>/dev/null)" || return 0
    major="${v#v}"
    major="${major%%.*}"
    case "$major" in
        '' | *[!0-9]*) return 0 ;;
    esac
    if [ "$major" -lt 18 ]; then
        echo "경고: Node $v 는 너무 오래되었습니다 (18 이상 권장). 설치는 하지 않습니다"
    fi
}

install_optional() {
    local pkgs
    case "$1" in
        rust)
            if has_cmd rustup; then
                echo "rustup이 이미 설치되어 있어 건너뜀"
            else
                run sh -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
            fi
            ;;
        java)
            if [ "$PKG" = "brew" ]; then
                run brew install --cask temurin@21
            else
                pkg_install "$(pkg_names java)"
            fi
            ;;
        tmux)
            pkg_install "$(pkg_names tmux)"
            if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
                run git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
            fi
            ;;
        *)
            pkgs="$(pkg_names "$1")"
            # shellcheck disable=SC2086
            pkg_install $pkgs
            ;;
    esac
}

# 설치된 nvim 버전("0.11.2")을 출력한다. 없으면 빈 문자열
# MYNVIM_NVIM_VERSION이 설정되어 있으면(빈 값 포함) 그 값을 쓴다
detect_nvim_version() {
    if [ "${MYNVIM_NVIM_VERSION+set}" = "set" ]; then
        echo "$MYNVIM_NVIM_VERSION"
        return 0
    fi
    has_cmd nvim || return 0
    nvim --version 2>/dev/null | sed -n '1s/^NVIM v\([0-9][0-9.]*\).*/\1/p'
}

# 0.11 이상이면 0 (bash 3.2 호환: 숫자로 major/minor 비교)
nvim_version_ok() {
    local v="$1" major minor
    [ -n "$v" ] || return 1
    major="${v%%.*}"
    minor="${v#*.}"
    minor="${minor%%.*}"
    case "$major$minor" in
        '' | *[!0-9]*) return 1 ;;
    esac
    [ "$major" -gt 0 ] || [ "$minor" -ge 11 ]
}

ensure_nvim() {
    local v arch
    v="$(detect_nvim_version)"
    if nvim_version_ok "$v"; then
        echo "nvim ${v} 확인됨 (0.11 이상)"
        return 0
    fi
    echo "nvim 0.11 이상이 필요합니다 (현재: ${v:-없음})"
    if [ "$PKG" = "brew" ]; then
        run brew install neovim
        return 0
    fi
    case "${MYNVIM_ARCH:-$(uname -m)}" in
        x86_64) arch="x86_64" ;;
        aarch64 | arm64) arch="arm64" ;;
        *)
            err "지원하지 않는 아키텍처: ${MYNVIM_ARCH:-$(uname -m)}"
            exit 1
            ;;
    esac
    run mkdir -p "$HOME/.local/opt/nvim" "$HOME/.local/bin"
    run sh -c "curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz | tar -xz --strip-components=1 -C '$HOME/.local/opt/nvim'"
    run ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) echo "안내: $HOME/.local/bin 이 PATH에 없습니다. 셸 설정에 export PATH=\"\$HOME/.local/bin:\$PATH\" 를 추가하세요" ;;
    esac
}

main() {
    set -euo pipefail
    parse_args "$@"
    detect_platform
    choose_components

    echo "플랫폼: $PLATFORM"
    echo "패키지 관리자: $PKG"
    echo "선택 항목: ${WITH:-없음 (필수만)}"
    [ "$DRY_RUN" -eq 1 ] && echo "(dry-run: 변경 없음)"
    # 1) 패키지 설치 (Task 4에서 MYNVIM_SKIP_PACKAGES 분기 추가)
    install_core
    local c
    for c in $WITH; do
        install_optional "$c"
    done
    ensure_nvim
    # 2) 링크 단계, 3) Lazy 동기화는 Task 4에서 추가
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
