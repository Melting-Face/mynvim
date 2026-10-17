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

main() {
    set -euo pipefail
    parse_args "$@"
    detect_platform
    choose_components

    echo "플랫폼: $PLATFORM"
    echo "패키지 관리자: $PKG"
    echo "선택 항목: ${WITH:-없음 (필수만)}"
    [ "$DRY_RUN" -eq 1 ] && echo "(dry-run: 변경 없음)"
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
