# WezTerm 멀티플렉서

이 레포는 tmux 대신 WezTerm 자체 멀티플렉서를 씁니다. tmux는 Windows 네이티브에서 돌지 않아 OS마다 사용법이 갈라졌기 때문입니다.
설정은 [`wezterm.lua`](../wezterm.lua) 하나이고, macOS, Linux, Windows에서 같은 키로 동작합니다.

tmux를 쓰던 두 가지 용도를 그대로 제공합니다.

1. 셸 하나에서 여러 작업을 동시에 하기: 패널 분할과 탭
2. 터미널 앱을 꺼도 작업이 백그라운드에서 유지되기: 로컬 mux 서버

## 시작과 백그라운드 유지

macOS, Linux에서는 WezTerm을 켜면 항상 로컬 mux 서버(unix domain `unix`)에 붙습니다. 서버가 없으면 WezTerm이 `wezterm-mux-server`를 띄웁니다.
Windows는 로컬 모드(창 프로세스가 셸을 직접 가짐)로 둡니다. 2026-10-26 WezTerm `20240203-110809-5046fc22`의 `wezterm-mux-server`가
스택 오버플로(`0xc00000fd`)로 두 번 죽으며 모든 패널이 함께 끊겼기 때문입니다. Windows에서는 아래 백그라운드 유지 대신
[창이 사라졌을 때 다시 붙기](#창이-사라졌을-때-다시-붙기)가 작업을 지킵니다.
셸과 그 안의 작업은 창이 아니라 서버에서 돌기 때문에, 다음 경우에도 계속 실행됩니다.

- `prefix` + `d`로 떼어 냈을 때
- 창의 X 버튼으로 닫았을 때

WezTerm을 다시 열면 같은 탭과 패널에 그대로 다시 붙습니다.
X 버튼으로 닫아도 유지되는 것은 2026-10-21 Windows, WezTerm `20240203-110809-5046fc22`에서 확인했습니다.
창을 닫아도 서버에서 셸이 끝나지는 않으므로, 작업을 정말 끝내려면 셸에서 `exit`하거나 `prefix` + `x`(패널), `prefix` + `&`(탭)로 닫으세요.

재부팅하면 서버도 끝나므로 세션은 복원되지 않습니다(tmux도 마찬가지입니다).

## 창이 사라졌을 때 다시 붙기

창은 사라졌는데 WezTerm 프로세스는 남아 있으면 `prefix` + `s`로 다시 붙습니다(tmux `attach`). 모든 OS에서 같습니다.
예를 들어 Windows에서 그래픽 드라이버가 재설정되면(이벤트 로그 `nvlddmkm` 153 → 4101) WezTerm 로그에
`opengl context was lost`가 남고 창만 없어집니다. 그 안의 셸과 작업은 계속 돕니다.

1. 새 WezTerm 창을 엽니다.
2. `prefix` + `s`로 도메인 목록을 열고 `gui-<PID>`를 고릅니다. `<PID>`는 창이 사라진 WezTerm 프로세스 번호입니다.
3. 그 프로세스의 탭과 패널이 지금 창에 붙습니다. 셸은 원래 프로세스가 계속 가지므로, 붙은 창이 다시 사라져도 같은 방법으로 붙습니다.

WezTerm 창 프로세스는 각자 mux 소켓 `gui-sock-<PID>`를 엽니다. 위치는 Linux가 `$XDG_RUNTIME_DIR/wezterm`, 그 밖은 `~/.local/share/wezterm`입니다.
`wezterm.lua`가 시작할 때 살아 있는 다른 WezTerm 프로세스의 소켓을 찾아 도메인 `gui-<PID>`로 등록합니다.
자기 자신과, 프로세스가 끝나 파일만 남은 소켓은 빠집니다. 그래서 목록은 새 창을 연 시점의 상태입니다.

창을 X 버튼으로 닫으면 로컬 모드에서는 그 프로세스와 셸도 함께 끝나므로 다시 붙을 수 없습니다. 일부러 떼어 두려면 mux 서버를 쓰는 OS에서 `prefix` + `d`를 쓰세요.

Windows에서는 창이 사라지지 않도록 화면을 GPU 대신 CPU로 그립니다(`wezterm.lua`의 `config.front_end = "Software"`).
글자 그리기가 느리게 느껴지면 그 블록을 주석 처리해 기본(OpenGL)으로 돌리세요.

Linux에서 실제 창 두 개로 다시 붙는 과정은 [`tests/wezterm_reattach_test.sh`](../tests/wezterm_reattach_test.sh)가 CI에서 확인합니다.
macOS와 Windows는 CI에서 도메인 등록까지만 확인합니다. 쓰고 있는 WezTerm에 영향이 없도록 이 시험은 컨테이너나 CI에서 실행하세요.

## 기본 키

prefix는 `C-a`입니다. 아래 `prefix`는 `Ctrl+a`를 누른 뒤 뗀다는 뜻이고, 1초 안에 다음 키를 눌러야 합니다.
prefix가 눌려 있으면 오른쪽 상태줄에 `PREFIX`가 표시됩니다.

| 키 | 동작 |
| --- | --- |
| `prefix` + `"` / `%` | 위아래 / 좌우로 패널 분할 |
| `prefix` + 방향키 또는 `h` / `j` / `k` / `l` | 패널 이동 |
| `prefix` + `H` / `J` / `K` / `L` | 패널 크기 2칸 조절. 0.5초 안에 `H`/`J`/`K`/`L`를 다시 누르면 prefix 없이 반복 (`Esc`로 종료) |
| `prefix` + `z` | 패널 확대/복원 |
| `prefix` + `x` | 패널 닫기 (확인 후) |
| `prefix` + `c` | 새 탭 (tmux window) |
| `prefix` + `n` / `p` | 다음 / 이전 탭 |
| `prefix` + `0`~`9` | 해당 번호 탭으로 이동. 탭 바에 보이는 번호와 같고 tmux처럼 0부터 |
| `prefix` + `w` | 탭 목록 |
| `prefix` + `,` | 탭 이름 바꾸기 |
| `prefix` + `&` | 탭 닫기 (확인 후) |
| `prefix` + `[` | 복사 모드 (vi 키) |
| `prefix` + `d` | mux 서버에서 떼어 내기 (작업은 계속 실행) |
| `prefix` + `s` | 도메인 목록에서 골라 붙기. 창이 사라진 WezTerm(`gui-<PID>`)에 다시 붙을 때 |
| `prefix` + `C-a` | 셸이나 nvim에 `C-a` 전달 |
| `prefix` + `C-l` | 셸에 `C-l` 전달 (화면 지우기) |

## nvim과 패널 사이 이동

`C-h/j/k/l`은 nvim 창과 WezTerm 패널을 구분하지 않고 이동하고, `A-h/j/k/l`은 크기를 조절합니다(tmux.nvim을 쓰던 때와 같은 키).

- nvim 안에서는 nvim 창 사이를 먼저 움직이고, 그 방향에 nvim 창이 없으면 `wezterm cli`로 옆 WezTerm 패널로 넘어갑니다.
- 셸 패널에서는 WezTerm이 키를 받아 패널을 움직입니다. 그래서 셸의 `C-l`(화면 지우기)은 `prefix` + `C-l`로 보냅니다.
- nvim은 시작할 때와 포커스를 얻을 때(떼었다 다시 붙은 경우 포함) user var `IS_NVIM`을 알리고, 종료·일시 중지(`C-z`) 때 지웁니다.
  WezTerm은 이 값으로 키를 nvim에 넘길지 정합니다. 다시 붙은 직후 nvim 패널에서 키가 패널 이동으로 처리되면 그 패널을 한 번 클릭해 포커스를 주세요.
  nvim이 비정상 종료해 값이 남으면 그 패널에서 `C-h` 등이 셸로 갑니다. 이때는 `prefix` + `h/j/k/l`로 이동하세요.
- WezTerm 패널에서 SSH로 접속한 원격 nvim도 이 설정을 쓰면 값을 알리므로 키를 받습니다. 다만 원격 nvim 창 끝에서 옆 WezTerm 패널로 넘어가지는 않습니다(`prefix` + `h/j/k/l` 사용).
  이 설정이 없는 nvim(`nvim --clean`, 원격의 다른 설정)에서는 WezTerm이 키를 먼저 가져가므로 nvim 창 이동은 `C-w h` 등 nvim 기본 키를 쓰세요.
- 다른 터미널의 nvim에서는 nvim 창 안에서만 동작합니다.

연동은 [`lua/configs/wezterm_nav.lua`](../lua/configs/wezterm_nav.lua)와 `wezterm.lua`에 있습니다. 플러그인을 받지 않으므로 오프라인에서도 동작합니다.

## 설정을 바꾼 뒤

mux 서버도 같은 `wezterm.lua`를 읽습니다. 키 같은 GUI 설정은 바로 다시 읽히지만, 기본 셸(`default_prog`)처럼 서버가 쓰는 설정은 서버를 다시 시작해야 적용됩니다.
서버를 끄면 그 안의 모든 작업이 끝나니, 작업을 정리한 뒤에 실행하세요.

```powershell
# Windows
Stop-Process -Name wezterm-mux-server
```

```shell
# macOS, Linux
pkill wezterm-mux-server
```

그 뒤 WezTerm을 다시 열면 새 서버가 뜹니다. 서버에 있는 패널 목록은 `wezterm cli list`로 볼 수 있습니다.

## 문제가 생기면

mux 기능은 WezTerm 문서에서 "still a young feature"라고 밝힌 기능입니다([Multiplexing](https://wezterm.org/multiplexing.html)).
연결이나 표시가 불안정하면 `wezterm.lua`의 `config.default_gui_startup_args = { "connect", "unix" }` 줄을 주석 처리하세요.
예전처럼 창 안에서만 도는 로컬 모드로 돌아갑니다(키는 그대로, 백그라운드 유지만 없어짐).

## tmux와 다른 점

- `prefix` + `s`는 tmux처럼 세션 목록이 아니라 도메인 목록입니다(mux 서버와 창이 사라진 WezTerm). tmuxinator 같은 세션 관리는 없습니다.
- tmux 상태줄 위젯(onedark 테마, CPU, 배터리, 날짜)은 옮기지 않았습니다. 오른쪽 상태줄에는 `PREFIX`(와 크기 조절 중 키 테이블 이름)만 표시합니다.
- 색상은 nvim 테마와 맞춘 `Claude Dark` 스킴입니다. 패널이 여러 개면 비활성 패널은 어둡게, 패널 경계선과 지금 탭은 주황으로 표시합니다. 비활성 패널 밝기는 `wezterm.lua`의 `inactive_pane_hsb`에서 조정합니다.
- SSH 원격 서버에서의 세션 유지는 다루지 않습니다. 이 구성은 로컬 용도입니다.
- 예전 tmux 설정 파일 정리는 [README의 문제 해결](../README.md#예전-tmux-설정-정리)을 보세요.
