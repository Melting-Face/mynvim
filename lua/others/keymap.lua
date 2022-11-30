-- keymap can use string | function
-----------------------------------
local gs = require('gitsigns')
local wk = require('which-key')

wk.register({
  b = {
    name = 'buffer & breakpoint',
    a = { '<cmd>bufdo bd<CR>', 'buffer delete all' },
    b = { function () require"dap".toggle_breakpoint() end, 'breakpoint' },
    c = { '<cmd>bdelete<CR>', 'buffer close' },
    h = { '<cmd>sb<CR>', 'split horizontal' },
    v = { '<cmd>vs<CR>', 'spit vertical' },
  },
  c = {
    name = 'cmd',
    i = { function () IPython:toggle() end, 'ipython' },
    n = { function () Node:toggle() end, 'node' },
  },
  d = {
    name = 'dap',
    f = {
      function ()
        if vim.bo.filetype == 'python' then
          require'dap-python'.test_class()
        elseif vim.bo.filetype == 'java' then
          require'jdtls'.test_class()
        end
      end,
      'test class(python/java)'
    },
    g = { function () require'dap-go'.debug_test() end, 'test debug(go)' },
    l = { function () require'dap'.run_last() end, 'last run' },
    n = {
      function ()
        if vim.bo.filetype == 'python' then
          require'dap-python'.test_method()
        elseif vim.bo.filetype == 'java' then
          require'jdtls'.test_nearest_method()
        end
      end,
      'test method(python)'
    },
    r = { function () require'dap'.repl.open() end, 'open repl' },
    t = { function () require("dapui").toggle() end, 'open dap-ui' },
  },
  f = {
    name = 'find',
    b = { function () require('telescope.builtin').buffers() end, 'find buffers' },
    c = { function () require('telescope.builtin').git_bcommits() end, 'find git commits' },
    f = { function () require('telescope.builtin').find_files({ hidden=HIDDEN }) end, 'find files(telescope)' },
    g = { function () require('telescope.builtin').live_grep({ hidden=HIDDEN }) end, 'grep files' },
    h = {
      function ()
        HIDDEN = not HIDDEN
        vim.notify(
          tostring(HIDDEN),
          "info", {
            title = 'find hidden option',
            icon = "",
            timeout = 1000,
          }
        )
      end, 'find hidden option'
    },
    k = { function () require('telescope.builtin').keymaps() end, 'find keymap' },
    n = { '<cmd>NvimTreeFindFile<CR>', 'find files(nvim-tree)' },
    r = { function () require('telescope.builtin').registers() end, 'find register' },
    t = { function () require('telescope.builtin').git_commits() end, 'find total commits' },
  },
  h = {
    name = 'hunk',
    b = { function() gs.blame_line{ full=true } end, 'git blame all' },
    d = { gs.diffthis, 'diff this' },
    p = { gs.preview_hunk, 'preview huck' },
    r = { gs.reset_buffer, 'reset buffer' },
    s = { gs.stage_buffer, 'stage buffer' },
    u = { gs.undo_stage_hunk, 'undo stage' },
  },
  j = {
    name = 'jupyter with magma',
    c = { '<cmd>MagmaReevaluateCell<CR>', 'reevaluate cell' },
    d = { '<cmd>MagmaDelete<CR>', 'delete' },
    l = { '<cmd>MagmaEvaluateLine<CR>', 'evaluate line' },
    r = { '<cmd>MagmaEvaluateOperator<CR>', 'evaluate operator' },
    s = { '<cmd>MagmaShowOutput<CR>', 'show output' },
  },
  l = {
    name = 'lazy',
    d = { function () LazyDocker:toggle() end, 'lazy docker' },
    g = { function () LazyGit:toggle() end, 'lazy git' },
    n = { function () LazyNpm:toggle() end, 'lazy npm' },
    p = {
      function ()
        require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
      end,
      'set breakpoint with log point message',
    },
  },
  n = { '<cmd>NvimTreeToggle<CR>', 'nvim tree' },
  r = {
    name = 'rust_tools & rest-nvim',
    d = { '<cmd>RustDebuggables<CR>', 'rust debug' },
    h = {
      function ()
        if vim.bo.filetype == 'rust' then
          require("rust-tools").hover_actions.hover_actions()
        end
      end,
      'rust hover',
    },
    l = {
      function ()
        if vim.bo.filetype == 'http' then
          require('rest-nvim').last()
        end
      end,
      'rest nvim last',
    },
    n = {
      function ()
        if vim.bo.filetype == 'http' then
          require('rest-nvim').run()
        end
      end,
      'rest nvim run',
    },
    r = { '<cmd>RustRunnables<CR>', 'rust run' },
  },
  t = {
    name = 'tab & toggle',
    b = { gs.toggle_current_line_blame, 'gitsigns blame' },
    c = { '<cmd>tabclose<CR>', 'tab close' },
    x = { '<cmd>TroubleToggle<CR>', 'trouble' },
    d = { gs.toggle_deleted, 'gitsigns deleted' },
    n = { '<cmd>tabnew<CR>', 'new tab' },
    p = { '<cmd>MarkdownPreviewToggle<CR>', 'markdown preview' },
    s = { '<cmd>SymbolsOutline<CR>', 'symbols outline' },
    u = { '<cmd>DBUIToggle<CR>', 'db ui' }
  },
  u = {
    name = 'db ui',
    a = { '<cmd>DBUIAddConnection<CR>', 'add connection' },
    f = { '<cmd>DBUIFindBuffer<CR>', 'find buffer' },
    l = { '<cmd>DBUILastQueryInfo<CR>', 'last query info' },
    r = { '<cmd>DBUIRenameBuffer<CR>', 'rename buffer' },
  },
  B = {
    function ()
      require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end,
    'set breakpoint with condition',
  },
}, {
  prefix = '<leader>'
})

wk.register({
  e = {
    name = 'dapui',
    v = { function () require("dapui").eval() end, 'eval' },
  },
  h = {
    name = 'hunk',
    r = { gs.reset_buffer, 'reset buffer' },
    s = { gs.stage_buffer, 'stage buffer' },
    u = { gs.undo_stage_hunk, 'undo stage' },
  }
}, {
  mode = 'v',
  prefix = '<leader>',
})

wk.register({
  b = { '<cmd>bp<cr>', 'buffer previous' },
  c = {
    function()
      if vim.wo.diff then
        return '[c'
      end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end,
    'prev hunk',
  },
  d = { vim.diagnostic.goto_prev, 'diagnostic previous' },
  t = { '<cmd>tabprev<CR>', 'tab previous' },
}, {
  prefix = '['
})

wk.register({
  b = { '<cmd>bn<cr>', 'buffer next' },
  c = {
    function()
      if vim.wo.diff then
        return ']c'
      end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end,
    'next hunk',
  },
  d = { vim.diagnostic.goto_next, 'diagnostic next' },
  t = { '<cmd>tabnext<CR>', 'tab next' },
}, {
  prefix = ']'
})

wk.register({
  j = {
    name = 'jupyter with magma',
    l = { ':<C-u>MagmaEvaluateVisual<CR>', 'evaluate visual' }
  }
}, {
  mode = "v",
  prefix = '<leader>',
})

-- for nvim-dap
vim.keymap.set('n', '<F5>', function () require'dap'.continue() end, { silent = true })
vim.keymap.set('n', '<F10>', function () require'dap'.step_over() end, { silent = true })
vim.keymap.set('n', '<F11>', function () require'dap'.step_into() end, { silent = true })
vim.keymap.set('n', '<F12>', function () require'dap'.step_out() end, { silent = true })
-- for nvim-dap-python
vim.keymap.set('v', '<leader>ds <ESC>', function () require('dap-python').debug_selection() end, { silent = true })
-- for bufferlie
vim.keymap.set('n', '<leader>1', function () require("bufferline").go_to_buffer(1, true) end, { silent = true })
vim.keymap.set('n', '<leader>2', function () require("bufferline").go_to_buffer(2, true) end, { silent = true })
vim.keymap.set('n', '<leader>3', function () require("bufferline").go_to_buffer(3, true) end, { silent = true })
vim.keymap.set('n', '<leader>4', function () require("bufferline").go_to_buffer(4, true) end, { silent = true })
vim.keymap.set('n', '<leader>5', function () require("bufferline").go_to_buffer(5, true) end, { silent = true })
vim.keymap.set('n', '<leader>6', function () require("bufferline").go_to_buffer(6, true) end, { silent = true })
vim.keymap.set('n', '<leader>7', function () require("bufferline").go_to_buffer(7, true) end, { silent = true })
vim.keymap.set('n', '<leader>8', function () require("bufferline").go_to_buffer(8, true) end, { silent = true })
vim.keymap.set('n', '<leader>9', function () require("bufferline").go_to_buffer(9, true) end, { silent = true })
-- for wrap
vim.keymap.set('n', 'j', 'v:count ? "j" : "gj"', { expr = true })
vim.keymap.set('n', 'k', 'v:count ? "k" : "gk"', { expr = true })
