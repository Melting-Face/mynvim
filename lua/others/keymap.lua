-- keymap can use string | function
-----------------------------------
local gs = require('gitsigns')
local wk = require('which-key')

-- INFO: <leader> key (normal)
wk.register({
  b = { function () require"dap".toggle_breakpoint() end, 'breakpoint' },
  c = {
    name = 'current',
    n = { '<cmd>NvimTreeFindFile<CR>', 'find files(nvim-tree)' },
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
    c = { '<cmd>TodoTelescope<CR>', 'find todo comments' },
    f = { function () require('telescope.builtin').find_files({ hidden=HIDDEN_FILE }) end, 'find files(telescope)' },
    g = { function () require('telescope.builtin').live_grep({ hidden=HIDDEN_FILE }) end, 'grep files' },
    h = { function () require('telescope.builtin').git_bcommits() end, 'find git commits' },
    k = { function () require('telescope.builtin').keymaps() end, 'find keymap' },
    p = { '<cmd>Telescope projects<CR>', 'find projects' },
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
  l = {
    name = 'lazy',
    d = { '<cmd>lua _lazydocker()<CR>', 'lazy docker' },
    g = { '<cmd>lua _lazygit()<CR>', 'lazy git' },
    n = { '<cmd>lua _lazynpm()<CR>', 'lazy npm' },
    p = {
      function ()
        require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
      end,
      'set breakpoint with log point message',
    },
  },
  m = {
    name = 'Magma(jupyer)',
    c = { '<cmd>MagmaReevaluateCell<CR>', 'reevaluate cell' },
    d = { '<cmd>MagmaDelete<CR>', 'delete' },
    l = { '<cmd>MagmaEvaluateLine<CR>', 'evaluate line' },
    r = { '<cmd>MagmaEvaluateOperator<CR>', 'evaluate operator' },
    s = { '<cmd>MagmaShowOutput<CR>', 'show output' },
  },
  n = {
    name = 'Neo',
    g = { function () require'neogit'.open() end, 'neogit' },
    n = { '<cmd>Neogen<CR>', 'neogen' },
    s = { function () require('neotest').run.stop() end, 'neotest stop' },
    t = { function () require('neotest').run.run({ strategy = 'dap' }) end, 'neotest start' },
  },
  o = {
    name = 'options',
    h = {
      function ()
        HIDDEN_FILE = not HIDDEN_FILE
        vim.notify(
          tostring(HIDDEN_FILE),
          "info", {
            title = 'find hidden option',
            icon = "",
            timeout = 1000,
          }
        )
      end,
      'hidden(find files & grep files)'
    },
  },
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
    d = { gs.toggle_deleted, 'gitsigns deleted' },
    m = { '<cmd>MinimapToggle<CR>', 'minimap' },
    n = { '<cmd>NvimTreeToggle<CR>', 'nvim tree' },
    p = { '<cmd>MarkdownPreviewToggle<CR>', 'markdown preview' },
    t = { '<cmd>SymbolsOutline<CR>', 'Tagbar' },
    u = { '<cmd>DBUIToggle<CR>', 'db ui' },
    x = { '<cmd>TroubleToggle<CR>', 'trouble' },
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

-- INFO: <leader> key (visual)
wk.register({
  m = {
    name = 'jupyter with magma',
    l = { ':<C-u>MagmaEvaluateVisual<CR>', 'evaluate visual' }
  }
}, {
  mode = "v",
  prefix = '<leader>',
})

-- INFO: <space> key
wk.register({
  b = {
    name = 'buffer',
    a = { '<cmd>bufdo bd<CR>', 'buffer delete all' },
    h = { '<cmd>sb<CR>', 'split horizontal' },
    v = { '<cmd>vs<CR>', 'spit vertical' },
    x = { '<cmd>bdelete<CR>', 'buffer close' },
  },
  c = {
    name = 'Code',
    a = { vim.lsp.buf.code_action, 'Action' },
  },
  e = { vim.diagnostic.open_float, 'Open float' },
  f = { vim.lsp.buf.formatting, 'Lsp formatting' },
  q = { vim.diagnostic.setloclist, 'Set location list'},
  r = {
    name = 'Buffer',
    n = { vim.lsp.buf.rename, 'Lsp Rename' },
  },
  t = {
    name = 'tab',
    n = { '<cmd>tabnew<CR>', 'new tab' },
    x = { '<cmd>tabclose<CR>', 'tab close' },
  },
  w = {
    name = 'Workspace',
    a = { vim.lsp.buf.add_workspace_folder, 'Add' },
    l = {
      function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end,
      'List'
    },
    r = { vim.lsp.buf.remove_workspace_folder, 'Remove' }
  },
  D = { vim.lsp.buf.type_definition, 'Type definition' },
}, {
  prefix = '<space>'
})

-- INFO: 'g' key
wk.register({
  d = { vim.lsp.buf.definition, 'Go to definition' },
  i = { vim.lsp.buf.implementation, 'Go to implementation' },
  r = { vim.lsp.buf.references, 'Go to references' },
  D = { vim.lsp.buf.declaration, 'Go to declaration' },
}, {
  prefix = 'g'
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

-- INFO: '[' key
wk.register({
  b = { '<cmd>bp<cr>', 'buffer previous' },
  c = {
    function()
      require("todo-comments").jump_prev()
    end,
    'Previous todo comment',
  },
  d = { vim.diagnostic.goto_prev, 'diagnostic previous' },
  h = {
    function()
      if vim.wo.diff then
        return '[h'
      end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end,
    'prev hunk',
  },
  t = { '<cmd>tabprev<CR>', 'tab previous' },
}, {
  prefix = '['
})

-- INFO: ']' key
wk.register({
  b = { '<cmd>bn<cr>', 'buffer next' },
  c = {
    function()
      require("todo-comments").jump_next()
    end,
    'Next todo comment',
  },
  d = { vim.diagnostic.goto_next, 'diagnostic next' },
  h = {
    function()
      if vim.wo.diff then
        return ']c'
      end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end,
    'next hunk',
  },
  t = { '<cmd>tabnext<CR>', 'tab next' },
}, {
  prefix = ']'
})

-- INFO: For lsp
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { silent = true })
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { silent = true })

-- INFO: For dap
vim.keymap.set('n', '<F5>', function () require'dap'.continue() end, { silent = true })
vim.keymap.set('n', '<F10>', function () require'dap'.step_over() end, { silent = true })
vim.keymap.set('n', '<F11>', function () require'dap'.step_into() end, { silent = true })
vim.keymap.set('n', '<F12>', function () require'dap'.step_out() end, { silent = true })

-- INFO: For dap-python
vim.keymap.set('v', '<leader>ds <ESC>', function () require('dap-python').debug_selection() end, { silent = true })

-- INFO: For bufferlie
vim.keymap.set('n', '<leader>1', function () require("bufferline").go_to_buffer(1, true) end, { silent = true })
vim.keymap.set('n', '<leader>2', function () require("bufferline").go_to_buffer(2, true) end, { silent = true })
vim.keymap.set('n', '<leader>3', function () require("bufferline").go_to_buffer(3, true) end, { silent = true })
vim.keymap.set('n', '<leader>4', function () require("bufferline").go_to_buffer(4, true) end, { silent = true })
vim.keymap.set('n', '<leader>5', function () require("bufferline").go_to_buffer(5, true) end, { silent = true })
vim.keymap.set('n', '<leader>6', function () require("bufferline").go_to_buffer(6, true) end, { silent = true })
vim.keymap.set('n', '<leader>7', function () require("bufferline").go_to_buffer(7, true) end, { silent = true })
vim.keymap.set('n', '<leader>8', function () require("bufferline").go_to_buffer(8, true) end, { silent = true })
vim.keymap.set('n', '<leader>9', function () require("bufferline").go_to_buffer(9, true) end, { silent = true })

-- INFO: For wrap
vim.keymap.set('n', 'j', '"gj"', { expr = true })
vim.keymap.set('n', 'k', '"gk"', { expr = true })
