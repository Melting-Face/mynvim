-- keymap can use string | function
-----------------------------------
local gs  = require('gitsigns')
local hop = require('hop')
local tt  = require("toggleterm.terminal").Terminal
local wk  = require('which-key')

local lazydocker = tt:new({
	cmd = "lazydocker",
	direction = "float",
	float_opts = {
		border = "single",
	},
})

local htop = tt:new({
  cmd = "htop",
  direction = "float",
	float_opts = {
		border = "single",
	},
})

-- INFO: no prefix hop keymap
wk.register({
  f = {
    function()
      hop.hint_char1()
    end,
    'hop 1',
  },
  F = {
    function()
      hop.hint_char2()
    end,
    'hop 2',
  },
}, {
  mode = '',
  noremap = false,
})

-- INFO: no prefix
wk.register({
  K =  { vim.lsp.buf.hover, 'vim lsp hover' },
  ['<F5>'] = { function () require'dap'.continue() end, 'dap run(continue)' },
  ['<F10>'] = { function () require'dap'.step_over() end, 'dap step over' },
  ['<F11>'] = { function () require'dap'.step_into() end, 'dap step into' },
  ['<F12>'] = { function () require'dap'.step_out() end, 'dap step out' },
})

-- INFO: <leader> key (normal)
wk.register({
  ['1'] = { function () require("bufferline").go_to_buffer(1, true) end, 'go to buffer index 1' },
  ['2'] = { function () require("bufferline").go_to_buffer(2, true) end, 'go to buffer index 2' },
  ['3'] = { function () require("bufferline").go_to_buffer(3, true) end, 'go to buffer index 3' },
  ['4'] = { function () require("bufferline").go_to_buffer(4, true) end, 'go to buffer index 4' },
  ['5'] = { function () require("bufferline").go_to_buffer(5, true) end, 'go to buffer index 5' },
  ['6'] = { function () require("bufferline").go_to_buffer(6, true) end, 'go to buffer index 6' },
  ['7'] = { function () require("bufferline").go_to_buffer(7, true) end, 'go to buffer index 7' },
  ['8'] = { function () require("bufferline").go_to_buffer(8, true) end, 'go to buffer index 8' },
  ['9'] = { function () require("bufferline").go_to_buffer(9, true) end, 'go to buffer index 9' },
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
    name = 'Telescope',
    b = { "<cmd>Telescope file_browser<CR>", 'file browser' },
    f = { function () require('telescope.builtin').find_files() end, 'find files' },
    g = {
      name = 'Git',
      {
        c = { function () require('telescope.builtin').git_bcommits() end, 'git commit log (buffer)' },
        t = { function () require('telescope.builtin').git_commits() end, 'git commit log (project)' },
      }
    },
    k = { function () require('telescope.builtin').keymaps() end, 'keymaps' },
    q = { function () require('telescope.builtin').quickfix() end, 'quickfix' },
    r = { function () require('telescope.builtin').registers() end, 'registers' },
    s = { function () require('telescope.builtin').live_grep() end, 'search' },
    u = { function () require("telescope").extensions.undo.undo() end, 'undo tree' },
  },
  h = {
    name = 'hunk',
    b = { function() gs.blame_line{ full=true } end, 'git blame all' },
    d = { gs.diffthis, 'diff this' },
    p = { gs.preview_hunk, 'preview huck' },
    r = { gs.reset_buffer, 'reset buffer' },
    s = { gs.stage_buffer, 'stage buffer' },
    t = { function () htop:toggle() end, 'htop'},
    u = { gs.undo_stage_hunk, 'undo stage' },
  },
  l = {
    name = 'lazy',
    d = { function () lazydocker:toggle() end, 'lazy docker' },
    p = {
      function ()
        require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
      end,
      'set breakpoint with log point message',
    },
  },
  n = {
    name = 'Neo',
    g = { '<cmd>Neogit<CR>', 'neogit' },
    n = { '<cmd>Neogen<CR>', 'neogen' },
  },
  q = {
    name = 'quickfix',
    p = {
      name = 'python',
      b = {
        function ()
          local query = "cexpr system('refurb --quiet " .. vim.fn.expand('%:p') .. "') | copen"
          vim.cmd(query)
        end,
        "Inspect current directory(refurb)"
      },
      d = {
        function ()
          local query = "cexpr system('refurb --quiet .') | copen"
          vim.cmd(query)
        end,
        "Inspect current directory(refurb)"
      },
    }
  },
  r = {
    name = 'rust_tools & rest-nvim & refactoring',
    b = { function () require('refactoring').refactor('Extract Block') end, 'refactoring extract block' },
    d = { '<cmd>RustDebuggables<CR>', 'rust debug' },
    f = {
      function () require('refactoring').refactor('Extract Block To File') end,
      'refactoring extract block to file',
    },
    h = {
      function ()
        if vim.bo.filetype == 'rust' then
          require("rust-tools").hover_actions.hover_actions()
        end
      end,
      'rust hover',
    },
    i = { function () require('refactoring').refactor('Inline Variable') end, 'refactoring inline variable' },
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
  s = {
    name = 'spectre',
    w = { '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', 'select word' },
    p = { '<cmd>lua require("spectre").open_file_search()<cr>', 'open file' },
  },
  t = {
    name = 'tab & toggle',
    c = { '<cmd>tabclose<CR>', 'tab close' },
    d = { '<cmd>DBUIToggle<CR>', 'db ui' },
    g = {
      name = 'gitsigns',
      b = { gs.toggle_current_line_blame, 'gitsigns blame' },
      d = { gs.toggle_deleted, 'gitsigns deleted' },
    },
    m = { '<cmd>MinimapToggle<CR>', 'minimap' },
    n = { '<cmd>NvimTreeToggle<CR>', 'nvim tree' },
    p = { '<cmd>MarkdownPreviewToggle<CR>', 'markdown preview' },
    t = { '<cmd>TagbarToggle<CR>', 'Tagbar' },
    a = { '<Plug>VimspectorContinue' },
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
  S = { '<cmd>lua require("spectre").open()<CR>', 'open spectre' },
}, {
  prefix = '<leader>'
})

-- INFO: <leader> key (visual)
wk.register({
  d = {
    s = { '<ESC>:lua require("dap-python").debug_selection()<CR>', 'python debug select' },
  },
  r = {
    name = 'refactoring',
    e = { function () require('refactoring').refactor('Extract Function') end, 'extract function' },
    f = { function () require('refactoring').refactor('Extract Function To File') end, 'extract function to file' },
    i = { function () require('refactoring').refactor('Inline Variable') end, 'inline variable'},
    v = { function () require('refactoring').refactor('Extract Variable') end, 'extract variable' },
  },
  s = {
    name = 'SnipRun',
    i = { '<cmd>SnipInfo<CR>', 'info' },
    r = { '<cmd>SnipRun<CR>', 'run' },
    s = { '<cmd>SnipReset<CR>', 'reset' },
    x = { '<cmd>SnipClose<CR>', 'close' },
  },
}, {
  mode = "v",
  prefix = '<leader>',
})

-- INFO: <space> key
wk.register({
  b = {
    name = 'buffer',
    a = { '<cmd>bufdo bd<CR>', 'buffer delete all' },
    x = { '<cmd>bdelete<CR>', 'buffer close' },
  },
  c = {
    name = 'Code',
    a = { vim.lsp.buf.code_action, 'Action' },
  },
  e = { vim.diagnostic.open_float, 'Open float' },
  f = { function () vim.lsp.buf.format { async = true } end, 'Lsp formatting' },
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
  },
  s = { '<esc>:lua require("spectre").open_visual()<CR>', 'spectre' },
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

-- INFO: For wrap
vim.keymap.set('n', 'j', '"gj"', { expr = true })
vim.keymap.set('n', 'k', '"gk"', { expr = true })
