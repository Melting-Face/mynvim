#!/usr/bin/env bash
# 창이 사라진 WezTerm에 다시 붙는 기능(wezterm.lua의 gui-<PID> 도메인)을 Linux에서 실제 창 두 개로 확인한다
# 창 A를 로컬 모드로 띄우고, 설정이 A의 소켓을 도메인으로 등록하는지와 창 B가 그 도메인에 붙어 A의 화면을 보는지 본다
# 필요: wezterm(GUI 포함), Xvfb. 쓰고 있는 WezTerm을 건드리지 않도록 컨테이너나 CI에서 실행한다
set -euo pipefail
cd "$(dirname "$0")/.."

export DISPLAY=:99
XDG_RUNTIME_DIR="$(mktemp -d)"
export XDG_RUNTIME_DIR
sockets="$XDG_RUNTIME_DIR/wezterm"
trap 'kill $(jobs -p) 2>/dev/null || true' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

# wait_socket <제외할 PID>: 제외 PID가 아닌 gui-sock-<PID>가 생길 때까지 최대 20초 기다려 PID를 출력한다
wait_socket() {
    local path pid
    for _ in $(seq 40); do
        for path in "$sockets"/gui-sock-*; do
            pid="${path##*-}"
            if [ -S "$path" ] && [ "$pid" != "$1" ]; then
                echo "$pid"
                return 0
            fi
        done
        sleep 0.5
    done
    return 1
}

Xvfb :99 -screen 0 1280x800x24 >/dev/null 2>&1 &
sleep 2

# 창 A: start로 띄우면 mux 서버 없이 창 프로세스가 셸을 직접 갖는다 (Windows 로컬 모드와 같은 상태)
wezterm --config-file wezterm.lua start --always-new-process -- bash -c 'echo MARKER_FROM_A; sleep 600' >/dev/null 2>&1 &
a="$(wait_socket none)" || fail "창 A의 gui-sock이 생기지 않음"
echo "창 A: PID $a"

# grep -q가 먼저 끝나면 pipefail 아래에서 wezterm이 SIGPIPE로 실패하므로 출력을 먼저 받는다
probe="$(wezterm --config-file tests/wezterm_probe.lua show-keys --lua 2>&1)"
grep -q "DOMAIN gui-$a\$" <<<"$probe" || fail "wezterm.lua가 gui-$a 도메인을 등록하지 않음"
echo "PASS 도메인 gui-$a 등록"

# 창 B: A의 도메인에 붙는다 (prefix + s 목록에서 고르는 것과 같은 도메인)
wezterm --config-file wezterm.lua connect "gui-$a" >/dev/null 2>&1 &
b="$(wait_socket "$a")" || fail "창 B의 gui-sock이 생기지 않음"
echo "창 B: PID $b"

export WEZTERM_UNIX_SOCKET="$sockets/gui-sock-$b"
for _ in $(seq 20); do
    for pane in $(wezterm cli --no-auto-start list --format json 2>/dev/null | grep -oE '"pane_id": *[0-9]+' | grep -oE '[0-9]+$'); do
        text="$(wezterm cli --no-auto-start get-text --pane-id "$pane" 2>/dev/null || true)"
        if grep -q MARKER_FROM_A <<<"$text"; then
            echo "PASS 창 B에서 창 A의 셸 화면이 보임 (pane $pane)"
            exit 0
        fi
    done
    sleep 0.5
done
fail "창 B에서 창 A의 셸 화면이 보이지 않음"
