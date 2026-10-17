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
# 사용자 셸의 원래 PATH (설치 중 ~/.local/bin을 앞에 붙이기 전 값, PATH 경고 판단용)
ORIG_PATH="$PATH"

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
PACMAN_SYNCED=0
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
                apt) echo "git ripgrep nodejs npm python3 python3-pip python3-venv build-essential curl unzip xz-utils $(clipboard_pkg)" ;;
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
        pacman)
            # 새 컨테이너/설치 직후에는 패키지 DB가 없으므로 처음 한 번은 -Syu로 동기화 (부분 업그레이드 방지)
            if [ "$PACMAN_SYNCED" -eq 0 ]; then
                run $SUDO pacman -Syu --noconfirm --needed "$@"
                PACMAN_SYNCED=1
            else
                run $SUDO pacman -S --noconfirm --needed "$@"
            fi
            ;;
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
    ensure_node
}

# 버전 문자열("20.11.0")의 major 숫자를 출력한다 (숫자가 아니거나 비어 있으면 0)
version_major() {
    local major="${1%%.*}"
    case "$major" in
        '' | *[!0-9]*) echo 0 ;;
        *) echo "$major" ;;
    esac
}

# 설치된 Node 버전("20.11.0")을 출력한다. 없으면 빈 문자열
# 이전 실행에서 설치한 ~/.local/bin/node가 18 이상이면 그것을 쓴다
# MYNVIM_NODE_VERSION이 설정되어 있으면(빈 값 포함) PATH의 node 대신 그 값을 쓴다 (테스트용)
detect_node_version() {
    local v=""
    if [ -x "$HOME/.local/bin/node" ]; then
        v="$("$HOME/.local/bin/node" -v 2>/dev/null || true)"
        v="${v#v}"
        if [ "$(version_major "$v")" -ge 18 ]; then
            echo "$v"
            return 0
        fi
    fi
    if [ "${MYNVIM_NODE_VERSION+set}" = "set" ]; then
        v="$MYNVIM_NODE_VERSION"
    elif has_cmd node; then
        v="$(node -v 2>/dev/null || true)"
    fi
    echo "${v#v}"
}

# Node 18 이상을 보장한다 (spec §6)
# brew는 경고만 하고, 그 밖에는 공식 LTS(v22) tarball을 ~/.local/opt/node에 풀고 ~/.local/bin에 링크한다
ensure_node() {
    local v arch dir b
    v="$(detect_node_version)"
    if [ "$(version_major "$v")" -ge 18 ]; then
        return 0
    fi
    if [ "$PKG" = "brew" ]; then
        if [ -n "$v" ]; then
            echo "경고: Node v$v 는 너무 오래되었습니다 (18 이상 권장). 설치는 하지 않습니다"
        fi
        return 0
    fi
    echo "Node 18 이상이 필요합니다 (현재: ${v:-없음}). 공식 LTS tarball을 ~/.local/opt/node에 설치합니다"
    case "${MYNVIM_ARCH:-$(uname -m)}" in
        x86_64) arch="x64" ;;
        aarch64 | arm64) arch="arm64" ;;
        *)
            err "지원하지 않는 아키텍처: ${MYNVIM_ARCH:-$(uname -m)}"
            exit 1
            ;;
    esac
    dir="$HOME/.local/opt/node"
    run mkdir -p "$dir" "$HOME/.local/bin"
    # SHASUMS256.txt에서 정확한 파일 이름을 찾아 받고, 체크섬을 검증한 뒤 푼다 (경로는 위치 인자로 전달)
    # shellcheck disable=SC2016  # $1, $2 등은 sh -c 안에서 확장되어야 한다
    run sh -c 'set -e; base=https://nodejs.org/dist/latest-v22.x; line=$(curl -fsSL "$base/SHASUMS256.txt" | grep " node-v[0-9.]*-linux-$1\.tar\.xz$" | head -n 1); [ -n "$line" ] || { echo "Node tarball을 찾지 못함" >&2; exit 1; }; file=${line##* }; tmp=$(mktemp -d); curl -fsSL -o "$tmp/$file" "$base/$file"; (cd "$tmp" && printf "%s\n" "$line" | sha256sum -c -); tar -xJf "$tmp/$file" --strip-components=1 -C "$2"; rm -rf "$tmp"' _ "$arch" "$dir"
    for b in node npm npx; do
        run ln -sf "$dir/bin/$b" "$HOME/.local/bin/$b"
    done
    use_local_bin
    warn_local_bin_shadowed node
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

# 주어진 nvim 실행 파일의 버전("0.11.2")을 출력한다
nvim_version_of() {
    "$1" --version 2>/dev/null | sed -n '1s/^NVIM v\([0-9][0-9.]*\).*/\1/p'
}

# PATH에 있는 nvim 버전("0.11.2")을 출력한다. 없으면 빈 문자열
# MYNVIM_NVIM_VERSION이 설정되어 있으면(빈 값 포함) 그 값을 쓴다
detect_nvim_version() {
    if [ "${MYNVIM_NVIM_VERSION+set}" = "set" ]; then
        echo "$MYNVIM_NVIM_VERSION"
        return 0
    fi
    has_cmd nvim || return 0
    nvim_version_of nvim
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

# 이 스크립트의 PATH 맨 앞에 ~/.local/bin을 둔다 (이후 단계에서 방금 설치한 nvim, node를 찾도록)
use_local_bin() {
    case "$PATH" in
        "$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
}

# 사용자 셸(원래 PATH)에서 이름이 ~/.local/bin의 것으로 잡히지 않으면 PATH 순서를 안내한다
warn_local_bin_shadowed() {
    local name="$1" found
    found="$(
        PATH="$ORIG_PATH"
        command -v "$name" 2>/dev/null || true
    )"
    if [ "$found" != "$HOME/.local/bin/$name" ]; then
        echo "경고: 셸에서 $name 을(를) 실행하면 ${found:-아무것도 없음}이(가) 잡힙니다. ~/.local/bin을 PATH 맨 앞에 두세요(셸 설정에 추가): export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

ensure_nvim() {
    local v arch local_nvim="$HOME/.local/bin/nvim"
    # 이전 실행에서 설치한 ~/.local/bin/nvim이 0.11 이상이면 다시 받지 않는다 (PATH에 오래된 nvim이 먼저 있어도)
    if [ -x "$local_nvim" ]; then
        v="$(nvim_version_of "$local_nvim")"
        if nvim_version_ok "$v"; then
            echo "nvim ${v} 확인됨 ($local_nvim)"
            use_local_bin
            warn_local_bin_shadowed nvim
            return 0
        fi
    fi
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
    # 경로는 sh -c 문자열에 끼워 넣지 않고 위치 인자로 전달한다
    # shellcheck disable=SC2016  # $1, $2는 sh -c 안에서 확장되어야 한다
    run sh -c 'curl -fsSL "$1" | tar -xz --strip-components=1 -C "$2"' _ \
        "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz" "$HOME/.local/opt/nvim"
    run ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$local_nvim"
    # 이후 단계(Lazy 동기화)에서 방금 설치한 nvim을 찾도록 이 스크립트의 PATH에 추가
    use_local_bin
    warn_local_bin_shadowed nvim
}

# 경로의 물리 경로를 출력한다 (디렉터리는 cd -P, 파일은 부모 디렉터리만 해석; bash 3.2 호환)
physical_path() {
    local p="$1"
    if [ -d "$p" ]; then
        (cd -P "$p" 2>/dev/null && pwd -P)
    else
        local d
        d="$(cd -P "$(dirname "$p")" 2>/dev/null && pwd -P)" || return 1
        echo "$d/$(basename "$p")"
    fi
}

# dst가 이미 src를 가리키거나 같은 경로인지 확인한다
is_linked() {
    local src_phys="$1" dst="$2" target
    if [ -L "$dst" ]; then
        target="$(readlink "$dst")"
        case "$target" in
            /*) ;;
            *) target="$(dirname "$dst")/$target" ;;
        esac
        [ "$(physical_path "$target" 2>/dev/null)" = "$src_phys" ] && return 0
    fi
    [ -e "$dst" ] && [ "$(physical_path "$dst" 2>/dev/null)" = "$src_phys" ]
}

# 경로 $1이 디렉터리 $2의 하위 경로이면 0 (같은 경로는 하위가 아님)
is_inside() {
    [ -n "$2" ] || return 1
    case "$1/" in
        "${2%/}/"?*) return 0 ;;
    esac
    return 1
}

# dst를 src로 향하는 심볼릭 링크로 만든다. 기존 대상은 지우지 않고 백업한다
link_path() {
    local src="$1" dst="$2" src_phys bak stamp n
    src_phys="$(physical_path "$src")"
    if is_linked "$src_phys" "$dst"; then
        echo "already linked: $dst"
        return 0
    fi
    # 레포가 대상 안에 clone된 경우: 대상을 백업(mv)하면 레포까지 옮겨지므로 아무것도 바꾸지 않고 중단한다
    # (대상이 심볼릭 링크면 mv는 링크만 옮기므로 물리 경로 비교는 실제 디렉터리일 때만 한다)
    if is_inside "$src" "$dst" \
        || { [ ! -L "$dst" ] && is_inside "$src_phys" "$(physical_path "$dst" 2>/dev/null || true)"; }; then
        err "레포($src)가 연결 대상($dst) 안에 있습니다. 레포를 다른 곳(예: ~/mynvim)에 clone한 뒤 다시 실행하세요"
        exit 1
    fi
    run mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        stamp="$(date +%Y%m%d-%H%M%S)"
        bak="$dst.bak.$stamp"
        n=0
        while [ -e "$bak" ] || [ -L "$bak" ]; do
            n=$((n + 1))
            bak="$dst.bak.$stamp-$n"
        done
        echo "백업: $dst -> $bak"
        run mv "$dst" "$bak"
    fi
    run ln -s "$src" "$dst"
}

# nvim 설정과 선택한 항목의 설정 파일을 연결한다
link_configs() {
    link_path "$REPO_DIR" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    case " $WITH " in
        *" tmux "*) link_path "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf" ;;
    esac
    if [ "$PLATFORM" = "wsl" ]; then
        echo "WSL: WezTerm 설정은 Windows 쪽(%USERPROFILE%\\.wezterm.lua)에서 관리하므로 건너뜀"
    elif has_cmd wezterm; then
        link_path "$REPO_DIR/wezterm.lua" "$HOME/.wezterm.lua"
    else
        echo "WezTerm이 감지되지 않아 ~/.wezterm.lua 연결을 건너뜀 (WezTerm 설치 후 다시 실행하세요)"
    fi
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
    # MYNVIM_SKIP_PACKAGES=1이면 패키지 설치와 Lazy 동기화를 건너뜀 (테스트용, dry-run은 출력만 하므로 무시)
    local do_packages=1
    if [ "${MYNVIM_SKIP_PACKAGES:-}" = "1" ] && [ "$DRY_RUN" -eq 0 ]; then
        do_packages=0
    fi
    # 1) 패키지 설치
    if [ "$do_packages" -eq 1 ]; then
        install_core
        local c
        for c in $WITH; do
            install_optional "$c"
        done
        ensure_nvim
    fi
    # 2) 설정 연결 (기존 대상은 백업)
    link_configs
    # 3) 플러그인 동기화
    if [ "$do_packages" -eq 1 ]; then
        run nvim --headless "+Lazy! sync" +qa
    fi
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
