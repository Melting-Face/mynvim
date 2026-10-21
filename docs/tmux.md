# tmux

tmux는 [설치 스크립트](../README.md#설치-옵션)의 선택 항목입니다. 네이티브 Windows에서는 지원하지 않습니다(WSL에서는 사용 가능).
네이티브 Windows에서는 [WezTerm 멀티플렉서를 tmux 키로](#windows-네이티브-wezterm-멀티플렉서) 쓸 수 있습니다.

```shell
./install.sh --with tmux
```

설치하면 tmux, 플러그인 관리자 tpm(`~/.tmux/plugins/tpm`), `~/.tmux.conf` 링크(이 레포의 [`tmux.conf`](../tmux.conf))가 준비됩니다.

## 기본 키

prefix는 `C-a`입니다(기본값 `C-b`에서 바꿨습니다). 아래 `prefix`는 `Ctrl+a`를 누른 뒤 뗀다는 뜻입니다.

| 키 | 동작 |
| --- | --- |
| `prefix` + `J` / `K` / `H` / `L` | 패널 크기를 아래 / 위 / 왼쪽 / 오른쪽으로 2칸 조절 (반복 가능) |
| `prefix` + `C-a` | 안쪽 tmux나 프로그램에 `C-a` 전달 |

그 외 설정은 다음과 같습니다.

- 마우스 사용 켜짐
- 복사 모드는 vi 키
- 히스토리 50000줄
- 터미널: `tmux-256color` terminfo가 있으면 그것을 쓰고(italic 지원), 없으면 `screen-256color`를 씁니다. 두 경우 모두 nvim 트루컬러가 tmux 안에서도 보입니다.

## 플러그인

플러그인은 [tpm](https://github.com/tmux-plugins/tpm)으로 관리합니다.

- [tpm](https://github.com/tmux-plugins/tpm)

- [sensible](https://github.com/tmux-plugins/tmux-sensible)

- [one dark](https://github.com/odedlaz/tmux-onedark-theme)

- [cpu](https://github.com/tmux-plugins/tmux-cpu)

- [battery](https://github.com/tmux-plugins/tmux-battery)

- [prefix highlight](https://github.com/tmux-plugins/tmux-prefix-highlight)

`tmux.conf`에는 [logging](https://github.com/tmux-plugins/tmux-logging)과 [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)도 선언되어 있습니다.

### tpm 사용법

| 키 | 동작 |
| --- | --- |
| `prefix` + `I` | 플러그인 설치 |
| `prefix` + `U` | 플러그인 업데이트 |
| `prefix` + `alt` + `u` | 목록에서 지워진 플러그인 삭제 |

처음 tmux를 켠 뒤 플러그인이 보이지 않으면 `prefix` + `I`를 누르세요.
tpm이 없다면 직접 설치합니다.

```shell
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Windows 네이티브: WezTerm 멀티플렉서

tmux는 Windows 네이티브 빌드가 없어서, Windows에서는 [`wezterm.lua`](../wezterm.lua)가 WezTerm 자체 패널·탭 기능을 tmux와 같은 키로 묶어 둡니다.
prefix는 똑같이 `C-a`이고, prefix를 누른 뒤 1초 안에 다음 키를 눌러야 합니다. prefix가 눌려 있으면 오른쪽 상태줄에 `PREFIX`가 표시됩니다.
이 키는 Windows에서만 적용됩니다. macOS, Linux, WSL에서는 진짜 tmux가 `C-a`를 받습니다.

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
| `prefix` + `C-a` | 셸이나 nvim에 `C-a` 전달 |

tmux와 다른 점은 다음과 같습니다.

- 세션 detach/attach(`prefix` + `d`), tpm 플러그인, tmuxinator는 없습니다.
- WezTerm 안에서 WSL tmux를 함께 쓰면 바깥의 WezTerm이 `C-a`를 먼저 받습니다. 안쪽 tmux에 prefix를 보내려면 `C-a`를 두 번 누르세요(중첩 tmux와 같은 방식).

## tmuxinator

[tmuxinator](https://github.com/tmuxinator/tmuxinator)는 tmux 세션 구성을 프로젝트별 설정 파일로 관리하는 도구입니다.

### 설치

```shell
gem install tmuxinator
```

### 프로젝트

새 프로젝트를 만듭니다.

```shell
tmuxinator new [project]
```

프로젝트를 시작합니다.

```shell
tmuxinator start [project]
```

### windows 설정

<b>root</b>

- tmux pane workspace path

<b>layout</b>

- even-horizontal

- even-vertical

- main-horizontal

- main-vertical

- tiled

<b>pane</b>

- execution programs
