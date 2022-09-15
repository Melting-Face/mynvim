local Terminal  = require('toggleterm.terminal').Terminal
LazyGit = Terminal:new({
  cmd = "lazygit",
  direction = 'float',
  float_opts = {
    border = 'single',
  },
  hidden = true,
})

LazyDocker = Terminal:new({
  cmd = "lazydocker",
  direction = 'float',
  float_opts = {
    border = 'single',
  },
  hidden = true,
})

LazyNpm = Terminal:new({
  cmd = "lazynpm",
  direction = 'float',
  float_opts = {
    border = 'single',
  },
  hidden = true,
})
