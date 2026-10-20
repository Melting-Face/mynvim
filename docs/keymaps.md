# 키맵 전체 목록

이 설정에서 쓰는 키바인딩을 용도별로 정리했습니다. 자주 쓰는 키만 보려면 [README의 주요 키맵](../README.md#주요-키맵-및-팁)을 보세요.

- leader 키는 `,`, localleader 키는 `;`입니다. 아래 표의 `,ff`는 `<leader>ff`, `;n`은 `<localleader>n`을 뜻합니다.
- `<space>`로 시작하는 키는 leader가 아니라 스페이스바 그대로입니다.
- 실행 중에는 `,fk`(Telescope keymaps)나 which-key 팝업으로 현재 등록된 키를 확인할 수 있습니다.
- 키 정의 위치: 플러그인 키는 [`lua/plugins/`](../lua/plugins/)의 각 플러그인 `keys`, 그 밖의 키는 [`lua/configs/keymaps.lua`](../lua/configs/keymaps.lua)에 있습니다.
- 모드 표기: `n` 노멀, `v` 비주얼, `o` 연산자 대기(예: `d`, `y` 다음).

## 목차

- [파일·검색](#파일검색)
- [버퍼·탭·이동](#버퍼탭이동)
- [편집](#편집)
- [LSP·포맷](#lsp포맷)
- [Treesitter 텍스트 오브젝트](#treesitter-텍스트-오브젝트)
- [Git](#git)
- [디버깅 (DAP)·테스트](#디버깅-dap테스트)
- [DB](#db)
- [Claude Code](#claude-code)
- [자동 완성 (nvim-cmp)](#자동-완성-nvim-cmp)
- [기타](#기타)

## 파일·검색

| 키 | 모드 | 동작 | 플러그인 |
| --- | --- | --- | --- |
| `,ff` | n | 파일 찾기 | telescope |
| `,fs` | n | 내용 검색 (live grep) | telescope |
| `,fk` | n | 키맵 검색 | telescope |
| `,fq` | n | quickfix 목록 | telescope |
| `,fr` | n | 레지스터 목록 | telescope |
| `,fgc` | n | 현재 버퍼의 git 커밋 기록 | telescope |
| `,fgt` | n | 프로젝트 git 커밋 기록 | telescope |
| `;n` | n | 파일 트리 토글 | nvim-tree |
| `,nf` | n | 파일 트리에서 현재 파일 찾기 | nvim-tree |

## 버퍼·탭·이동

| 키 | 모드 | 동작 | 플러그인 |
| --- | --- | --- | --- |
| `,1` ~ `,9` | n | N번째 버퍼로 이동 | bufferline |
| `[b`, `]b` | n | 이전, 다음 버퍼 | 기본 설정 |
| `[t`, `]t` | n | 이전, 다음 탭 | 기본 설정 |
| `<space>bx` | n | 현재 버퍼 닫기 | 기본 설정 |
| `<space>ba` | n | 모든 버퍼 닫기 | 기본 설정 |
| `<space>tn` | n | 새 탭 | 기본 설정 |
| `<space>tx` | n | 탭 닫기 | 기본 설정 |
| `f` | n, v | 한 글자로 점프 | hop |
| `F` | n, v | 두 글자로 점프 | hop |
| `j`, `k` | n | 줄바꿈된 화면 줄 단위로 이동 (`5j`처럼 횟수를 주면 실제 줄 단위) | 기본 설정 |
| `C-h/j/k/l` | n | nvim 창, tmux 패널 사이 이동 | tmux.nvim |

## 편집

| 키 | 모드 | 동작 | 플러그인 |
| --- | --- | --- | --- |
| `;u` | n | undo tree 토글 | undotree |
| `gcc`, `gc` | n, v | 줄 주석 토글 | Comment.nvim |
| `gbc`, `gb` | n, v | 블록 주석 토글 | Comment.nvim |
| `ys`, `ds`, `cs` | n | 괄호·따옴표 감싸기, 지우기, 바꾸기 | nvim-surround |
| `C-n` | n, v | 다중 커서 (단어 선택 추가) | vim-visual-multi |
| `,nn` | n | 주석 문서(docstring) 생성 | neogen |
| `:Tab /:` | v | `:` 기준으로 정렬 | tabular |
| `:Spectre` | 명령 | 프로젝트 전체 찾아 바꾸기 | nvim-spectre |

## LSP·포맷

LSP가 붙은 버퍼에서만 동작합니다.

| 키 | 모드 | 동작 |
| --- | --- | --- |
| `gd` | n | 정의로 이동 |
| `gD` | n | 선언으로 이동 |
| `gi` | n | 구현으로 이동 |
| `grr` | n | 참조 보기 (nvim 기본) |
| `gri` | n | 구현 목록 보기 (nvim 기본) |
| `grn` | n | 이름 바꾸기 (nvim 기본) |
| `gra` | n, v | 코드 액션 (nvim 기본) |
| `gO` | n | 문서 심볼 목록 (nvim 기본) |
| `K` | n | 문서 보기 (hover, nvim 기본) |
| `<space>D` | n | 타입 정의로 이동 |
| `<space>q` | n | 진단 목록을 location list로 |
| `,ca` | n, v | 코드 액션 |
| `<space>f` | n | 포맷 (none-ls, LSP) |
| `]d`, `[d` | n | 다음, 이전 진단으로 이동 (nvim 기본) |
| `,hp` | n | 현재 디렉터리에 refurb 실행 후 quickfix로 열기 |

## Treesitter 텍스트 오브젝트

treesitter 파서가 있는 모든 파일에서 동작합니다.

| 키 | 모드 | 동작 |
| --- | --- | --- |
| `af`, `if` | v, o | 함수 바깥, 안쪽 선택 |
| `ac`, `ic` | v, o | 클래스 바깥, 안쪽 선택 |
| `as` | v, o | 언어 스코프 선택 |
| `]m`, `[m` | n | 다음, 이전 함수 시작 |
| `]M`, `[M` | n | 다음, 이전 함수 끝 |
| `]]`, `[[` | n | 다음, 이전 클래스 시작 |
| `][`, `[]` | n | 다음, 이전 클래스 끝 |
| `]i`, `[i` | n | 다음, 이전 조건문(if) |
| `]o` | n | 다음 반복문 |
| `]s` | n | 다음 스코프 |
| `]z` | n | 다음 fold |
| `,sn` | n | 파라미터를 다음 파라미터와 바꾸기 (swap next) |
| `,sp` | n | 파라미터를 이전 파라미터와 바꾸기 (swap previous) |

## Git

| 키 | 모드 | 동작 | 플러그인 |
| --- | --- | --- | --- |
| `,ng` | n | Neogit 열기 | neogit |
| `:G` | 명령 | Fugitive 상태 창 (`s` stage, `u` unstage, `cc` commit) | vim-fugitive |
| `,hb` | n | 현재 줄 git blame 토글 | gitsigns |
| `,hd` | n | 삭제된 줄 표시 토글 | gitsigns |
| `,ht` | n | 현재 파일 diff | gitsigns |
| `]h`, `[h` | n | 다음, 이전 변경 덩어리(hunk) | gitsigns |
| `co`, `ct`, `cb`, `c0` | n | 충돌 해결: ours, theirs, both, none | git-conflict |
| `]x`, `[x` | n | 다음, 이전 충돌 | git-conflict |

## 디버깅 (DAP)·테스트

| 키 | 모드 | 동작 |
| --- | --- | --- |
| `<F5>` | n | 디버그 시작, 계속 |
| `<F10>` | n | step over |
| `<F11>` | n | step into |
| `<F12>` | n | step out |
| `,b` | n | 중단점 토글 |
| `,B` | n | 중단점 설정 |
| `,lp` | n | 메시지를 남기는 중단점(log point) |
| `,dr` | n | REPL 열기 |
| `,dl` | n | 마지막 디버그 다시 실행 |
| `,dh` | n, v | 변수 값 보기 (hover) |
| `,dp` | n, v | 미리 보기 |
| `,df` | n | 호출 스택(frames) 창 |
| `,ds` | n | 스코프(scopes) 창 |
| `,dt` | n | DAP UI 토글 |
| `,dc` | n | 테스트 클래스 실행 (python 버퍼: dap-python, java 버퍼: jdtls) |
| `,dm` | n | 테스트 메서드 실행 (python 버퍼: dap-python, java 버퍼: jdtls) |
| `,dd` | n | 선택 영역 디버그 (python 버퍼에서만) |

## DB

| 키 | 모드 | 동작 | 플러그인 |
| --- | --- | --- | --- |
| `;d` | n | DB UI 토글 | vim-dadbod-ui |
| `,da` | n | DB 연결 추가 | vim-dadbod-ui |

## Claude Code

| 키 | 모드 | 동작 |
| --- | --- | --- |
| `,ac` | n | Claude Code 토글 |
| `,af` | n | Claude Code 창으로 포커스 |
| `,ar` | n | 이전 대화 이어서 열기 (`--resume`) |
| `,aC` | n | 마지막 대화 계속 (`--continue`) |
| `,am` | n | 모델 선택 |
| `,ab` | n | 현재 버퍼를 컨텍스트에 추가 |
| `,as` | v | 선택 영역을 Claude에 보내기 |
| `,as` | n | 파일 트리에서 선택한 파일 추가 (nvim-tree 등) |
| `,aa` | n | Claude가 제안한 diff 수락 |
| `,ad` | n | Claude가 제안한 diff 거절 |

## 자동 완성 (nvim-cmp)

| 키 | 모드 | 동작 |
| --- | --- | --- |
| `C-n`, `C-p` | 입력 | 다음, 이전 후보 |
| `<CR>` | 입력 | 후보 확정 |
| `C-e` | 입력 | 자동 완성 닫기 |

## 기타

| 키 | 모드 | 동작 | 플러그인 |
| --- | --- | --- | --- |
| `A-h/j/k/l` | n | 창 크기 조절 | tmux.nvim |
| `C-;` | 입력 | SQL omni 자동 완성 | 기본 설정 |

tmux와 WezTerm의 prefix 키는 [tmux 사용법](tmux.md)을 보세요.
