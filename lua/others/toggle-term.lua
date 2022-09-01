local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({
  cmd = "lazygit",
  direction = 'float',
  float_opts = {
    border = 'single',
  },
  hidden = true,
})

vim.keymap.set('n', '<leader>lg', function () lazygit:toggle() end)
