local Terminal  = require('toggleterm.terminal').Terminal
LazyGit = Terminal:new({
  cmd = "lazygit",
  direction = 'float',
  float_opts = {
    border = 'single',
  },
})

LazyDocker = Terminal:new({
  cmd = "lazydocker",
  direction = 'float',
  float_opts = {
    border = 'single',
  },
})

LazyNpm = Terminal:new({
  cmd = "lazynpm",
  direction = 'float',
  float_opts = {
    border = 'single',
  },
})

IPython = Terminal:new({
  cmd = "ipython",
  float_opts = {
    border = 'single',
  },
})

Node = Terminal:new({
  cmd = "node",
  float_opts = {
    border = 'single',
  },
})
