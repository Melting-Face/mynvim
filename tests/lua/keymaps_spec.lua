vim.opt.rtp:prepend(vim.fn.getcwd())
-- which-key 없이 keymaps.lua만 불러와 기본 키 매핑을 검사한다
package.loaded["which-key"] = { add = function() end }
require("configs.keymaps")

-- j/k: 횟수 없이 누르면 화면 줄 단위, 5j처럼 횟수를 주면 실제 줄 단위
assert(vim.fn.maparg("j", "n", false, true).rhs == [[v:count == 0 ? 'gj' : 'j']], "j 매핑")
assert(vim.fn.maparg("k", "n", false, true).rhs == [[v:count == 0 ? 'gk' : 'k']], "k 매핑")

-- LspAttach: nvim 0.11 기본 키(K, grr 등)와 겹치는 버퍼 로컬 매핑을 만들지 않는다
local buf = vim.api.nvim_get_current_buf()
vim.api.nvim_exec_autocmds("LspAttach", { buffer = buf, data = { client_id = 0 } })
assert(vim.fn.maparg("gr", "n", false, true).buffer ~= 1, "gr 버퍼 로컬 매핑이 grr 등을 가림")
assert(vim.fn.maparg("K", "n", false, true).buffer ~= 1, "K는 nvim 기본 hover 사용")
assert(vim.fn.maparg("gd", "n", false, true).buffer == 1, "gd 매핑")

-- 탭 닫기는 <space>tx 하나만 쓴다
assert(vim.fn.maparg(",tc", "n") == "", ",tc는 <space>tx와 중복")
os.exit(0)
