return {
  -- devicons
  "kyazdani42/nvim-web-devicons",
  -- async
  "nvim-lua/plenary.nvim",
  -- cache
  "lewis6991/impatient.nvim",
  -- tabular
  "godlygeek/tabular",
  -- whitespace
  "ntpeters/vim-better-whitespace",
  --undotree
  {
    'mbbill/undotree',
    keys = {
      {'<localleader>u', '<cmd>UndotreeToggle<CR>', 'undo tree'},
    }
  },
  -- minimap
  {
    "wfxr/minimap.vim",
    keys = {
      {'<localleader>m', '<cmd>MinimapToggle<CR>', desc='minimap'},
    }
  },
  -- startify
  'mhinz/vim-startify',

  -- INFO: TERMINAL/TMUX
  -- tmux
  {
    "aserowy/tmux.nvim",
    config = true,
  },
  -- toggleterm
  {
    "akinsho/toggleterm.nvim",
    config = true,
  },
  -- jqx
  {
    'gennaro-tedesco/nvim-jqx',
    ft = {
      "json",
      "yaml",
    },
  },
  -- spectre
  {
    'windwp/nvim-spectre',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      {'<leader>S', '<cmd>lua require("spectre").open()<CR>', desc="Open Spectre"},
      {'<leader>so', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', desc="Search current word"},
      {'<leader>so', '<esc>:lua require("spectre").open_visual()<CR>', desc="Search current word", mode='v'},
      {'<leader>sp', '<cmd>lua require("spectre").open_file_search()<cr>', desc = 'Search on current file'},
    },
    config = function ()
      require('spectre').setup()
    end
  },

  -- INFO: CURSOR
  -- multi cursor
  "mg979/vim-visual-multi",
  {
    'kevinhwang91/nvim-hlslens',
    config = function ()
      require('hlslens').setup()
      vim.cmd([[
        aug VMlens
          au!
          au User visual_multi_start lua require('hlslens').start()
          au User visual_multi_exit lua require('hlslens').stop()
        aug END
      ]])
    end,
  },
  -- HOP
  {
    "phaazon/hop.nvim",
    config = true,
    keys = {
      {'f', function() require('hop').hint_char1() end, desc='hop 1', mode=''},
      {'F', function() require('hop').hint_char2() end, desc='hop 2', mode=''},
    }
  },

  --telescope(fzf)
  {
    'ibhagwan/fzf-lua',
    event = 'VimEnter',
    keys = {
      {'<leader>ff', '<cmd>FzfLua files<cr>', desc='find files'},
      {'<leader>fgc', '<cmd>FzfLua git_bcommits<cr>', desc='git commit log (buffer)'},
      {'<leader>fgt', '<cmd>FzfLua git_commits<cr>', desc='git commit log (project)'},
      {'<leader>fk', '<cmd>FzfLua keymaps<cr>', desc='keymaps' },
      {'<leader>fq', '<cmd>FzfLua quickfix<cr>', desc='quickfix' },
      {'<leader>fr', '<cmd>FzfLua registers<cr>', desc='registers' },
      {'<leader>fs', '<cmd>FzfLua grep_visual<cr>', desc='search' },
    }
  },

  -- INFO: CSV
  -- rainbow csv
  {
    "mechatroner/rainbow_csv",
    lazy = true,
    ft = "csv",
  },
  -- csv.vim
  {
    "chrisbra/csv.vim",
    lazy = true,
    ft = "csv",
  },

  -- INFO: GIT
  -- vim-fugitive
  "tpope/vim-fugitive",
  -- neogit
  {
    'TimUntersberger/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
    },
    config = {
      integrations = {
        diffview = true
      },
      signs = {
        section = { "*", "=" },
        item = { "*", "=" },
        hunk = { "", "" },
      },
    },
    keys = {
      {'<leader>ng', '<cmd>Neogit<CR>', desc='neogit'},
    }
  },
  -- gitsigns
  {
    "lewis6991/gitsigns.nvim",
    config = {
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 250,
        ignore_whitespace = false,
      },
    },
    keys = {
      {'<leader>hb', '<cmd>Gitsigns toggle_current_line_blame<cr>', desc='curret line blame'},
      {'<leader>hd', '<cmd>Gitsigns toggle_deleted<cr>', desc='deleted'},
      {'<leader>ht', '<cmd>Gitsigns diffthis<cr>', desc='diff this'},
      {'[h', '<cmd>Gitsigns prev_hunk<cr>', desc='prev hunk'},
      {']h', '<cmd>Gitsigns next_hunk<cr>', desc='next hunk'},
    }
  },
  -- git congflict
  {
    'akinsho/git-conflict.nvim',
    config = true,
  },
  {
    'https://gitlab.com/yorickpeterse/nvim-pqf.git',
    config = function ()
      require('pqf').setup()
    end
  },

  -- quick fix
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    config = function()
      require('bqf').setup {}
    end
  },
  -- EMMET
  {
    "mattn/emmet-vim",
    ft = {
      "html",
      "javascriptreact",
      "typescriptreact",
    },
  },
  -- notify
  {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
    end,
  },
  -- theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function ()
      vim.cmd.colorscheme "catppuccin"
    end
  },
  -- nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "windwp/nvim-ts-autotag",
    },
    lazy = true,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.install").compilers = { "gcc-12" }
      require("nvim-treesitter.configs").setup({
        sync_install = true,
        ensure_installed = {
          "bash",
          "dockerfile",
          "graphql",
          "go",
          "html",
          "http",
          "java",
          "javascript",
          "json",
          "lua",
          "make",
          "markdown",
          "markdown_inline",
          "python",
          "regex",
          "rust",
          "toml",
          "tsx",
          "typescript",
          "yaml",
        },
        autotag = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["<leader>af"] = "@function.outer",
              ["<leader>if"] = "@function.inner",
              ["<leader>ac"] = "@class.outer",
              ["<leader>ic"] = "@class.inner",
            },
            selection_modes = {
              ["@parameter.outer"] = "v",
              ["@function.outer"] = "V",
              ["@class.outer"] = "<c-v>",
            },
            include_surrounding_whitespace = true,
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>as"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>As"] = "@parameter.inner",
            },
          },
        },
      })
    end,
  },
  -- neogen
  {
    "danymat/neogen",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    ft = {
      "go",
      "lua",
      "java",
      "javascript",
      "javascriptreact",
      "python",
      "rust",
      "sh",
      "typescript",
      "typescriptreact",
    },
    config = function()
      local lang_doc_map = {
        go = "godoc",
        lua = "ldoc",
        java = "javadoc",
        javascript = "jsdoc",
        javascriptreact = "jsdoc",
        python = "google_docstrings",
        rust = "rustdoc",
        sh = "google_bash",
        typescript = "tsdoc",
        typescriptreact = "tsdoc",
      }

      local languages = {}

      for lang, doc in ipairs(lang_doc_map) do
        languages[lang]["template"]["annotation_convention"] = doc
      end

      require("neogen").setup({
        enabled = true,
        snippet_engine = "luasnip",
        languages = languages,
      })
    end,
    keys = {
      {'<leader>nn', '<cmd>Neogen<CR>', desc='Neogen'}
    }
  },
  -- for winbar
  {
    "SmiteshP/nvim-navic",
    dependencies = "neovim/nvim-lspconfig",
    lazy = true,
    config = {
      highlight = true,
    },
  },
  -- vim dadbod
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
    },
    keys = {
      {'<localleader>d', '<cmd>DBUIToggle<CR>', desc='db ui'},
      {'<leader>da', '<cmd>DBUIAddConnection<CR>', desc='add connection'},
    }
  },

  -- PACKAGE
  -- package-info
  {
    "vuki656/package-info.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    ft = "json",
    event = {
      "BufRead package.json",
    },
    config = true,
  },
  -- crates
  {
    "saecki/crates.nvim",
    ft = "toml",
    event = {
      "BufRead Cargo.toml",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
  },
  -- restnvim
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("rest-nvim").setup({
        result_split_horizontal = false,
        result_split_in_place = false,
        skip_ssl_verification = false,
        encode_url = true,
        highlight = {
          enabled = true,
          timeout = 150,
        },
        result = {
          show_url = true,
          show_http_info = true,
          show_headers = true,
          formatters = {
            json = "jq",
            html = function(body)
              return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
            end,
          },
        },
        -- Jump to request line on run
        jump_to_request = false,
        env_file = ".env",
        custom_dynamic_variables = {},
        yank_dry_run = true,
      })
    end,
    keys = {
      {'<leader>rl', function () require('rest-nvim').last() end, desc='rest last'},
      {'<leader>rr', function () require('rest-nvim').run() end, desc='rest run'},
    }
  },
  -- mason
  {
    "williamboman/mason.nvim",
    config = true,
  },
  -- null_ls
  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        diagnostics_format = "[#{c}] #{m} (#{s})",
        debounce = 250,
        sources = {
          null_ls.builtins.diagnostics.eslint_d,
          null_ls.builtins.diagnostics.ruff,
          null_ls.builtins.diagnostics.golangci_lint,
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.luacheck,
          null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.diagnostics.yamllint,

          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.isort,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.eslint_d,
          null_ls.builtins.formatting.rustfmt,
          null_ls.builtins.formatting.shfmt,
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.sqlfmt,
          null_ls.builtins.formatting.taplo,
          null_ls.builtins.formatting.yamlfmt,
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {'<space>f', function() vim.lsp.buf.format { async = true } end, desc='LSP format'},
    }
  },
  -- mason null-ls
  {
    "jayp0521/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    config = {
      ensure_installed = {
        "black",
        "ruff",
        "eslint_d",
        "golangci_lint",
        "hadolint",
        "isort",
        "jq",
        "luacheck",
        "prettier",
        "remark",
        "rustfmt",
        "shellcheck",
        "shfmt",
        "sqlfmt",
        "stylua",
        "yamlfmt",
        "yamllint",
      },
      automatic_installation = true,
    },
  },
  -- markdown
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    setup = function()
      vim.g.mkdp_filetypes = { -- luacheck: ignore 112
        "markdown",
      }
    end,
    ft = {
      "markdown",
    },
    keys = {
      {'<localleader>p', '<cmd>MarkdownPreviewToggle<CR>', desc='markdown preview' },
    }
  },
  -- whici keys
  {
    "folke/which-key.nvim",
    config = true,
    lazy = true,
  },
  -- indent-blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    config = {
      show_end_of_line = true,
    },
  },
  -- bufferline
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "kyazdani42/nvim-web-devicons"
    },
    event = 'VimEnter',
    config = {
      options = {
        separator_style = "padded_slant",
        numbers = function(opts)
          return string.format("%s·%s", opts.raise(opts.id), opts.lower(opts.ordinal))
        end,
        diagnostics = "nvim_lsp",
        buffer_close_icon = '',
      },
    },
    keys = {
      {'<leader>1', '<cmd>BufferLineGoToBuffer 1<cr>', desc='goto buffer 1'},
      {'<leader>2', '<cmd>BufferLineGoToBuffer 2<cr>', desc='goto buffer 2'},
      {'<leader>3', '<cmd>BufferLineGoToBuffer 3<cr>', desc='goto buffer 3'},
      {'<leader>4', '<cmd>BufferLineGoToBuffer 4<cr>', desc='goto buffer 4'},
      {'<leader>5', '<cmd>BufferLineGoToBuffer 5<cr>', desc='goto buffer 5'},
      {'<leader>6', '<cmd>BufferLineGoToBuffer 6<cr>', desc='goto buffer 6'},
      {'<leader>7', '<cmd>BufferLineGoToBuffer 7<cr>', desc='goto buffer 7'},
      {'<leader>8', '<cmd>BufferLineGoToBuffer 8<cr>', desc='goto buffer 8'},
      {'<leader>9', '<cmd>BufferLineGoToBuffer 9<cr>', desc='goto buffer 9'},
    }
  },
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    config = {
      lightbulb = {
        enable = false,
      }
    },
    dependencies = {
      "kyazdani42/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {"gd", "<cmd>Lspsaga goto_definition<CR>", desc="goto definition"},
      {"gt", "<cmd>Lspsaga goto_type_definition<CR>", desc="goto type definition"},
      {"gh", "<cmd>Lspsaga lsp_finder<CR>", desc='lsp finder'},
      {"gr", "<cmd>Lspsaga rename<CR>", desc="rename"},

      {"<leader>ca", "<cmd>Lspsaga code_action<CR>", desc="code action", mode={'n', 'v'}},
      {"<leader>o", "<cmd>Lspsaga outline<CR>", desc="outline"},

      {"<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>", desc="show line"},
      {"<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>", desc="show buf"},
      {"<leader>sw", "<cmd>Lspsaga show_workspace_diagnostics<CR>", desc="show workspace"},
      {"<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", desc="show cursor"},

      {"K", "<cmd>Lspsaga hover_doc<CR>", desc="hover doc"},

      {"[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc="jump prev"},
      {"]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc="jump next"},
      {
        "[E",
        function()
          require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
        end,
        desc="jump prev error"
      },
      {
        "]E",
        function()
          require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
        end,
        desc="jump next error"
      }
    }
  },
  -- scope.nvim for tab
  {
    "tiagovla/scope.nvim",
    config = true,
  },

  -- INFO: DAP
  -- nvim-dap-ui
  {
    "rcarriga/nvim-dap-ui",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
    keys = {
      {'<leader>b', function () require"dap".toggle_breakpoint() end, desc='toggle breakpoint'},
      {'<leader>B', function() require('dap').set_breakpoint() end, desc='set breakpoint'},
      {
        '<Leader>lp',
        function()
          require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
        end,
        desc='set breakpoint with message',
      },
      {'<F5>', function () require'dap'.continue() end, desc='dap run(continue)'},
      {'<F10>', function () require'dap'.step_over() end, desc='dap step over'},
      {'<F11>', function () require'dap'.step_into() end, desc='dap step into'},
      {'<F12>', function () require'dap'.step_out() end, desc='dap step out'},
      {'<Leader>dr', function() require('dap').repl.open() end, desc='open repl'},
      {'<Leader>dl', function() require('dap').run_last() end, desc='run last'},
      {'<Leader>dh', function() require('dap.ui.widgets').hover() end, desc='dap ui widgets', mode={'n', 'v'}},
      {'<Leader>dp', function() require('dap.ui.widgets').preview() end, desc='dap ui preview', mode={'n', 'v'}},
      {
        '<Leader>df',
        function()
          local widgets = require('dap.ui.widgets')
          widgets.centered_float(widgets.frames)
        end,
        desc='dap ui widgets float center(frame)',
      },
      {
        '<Leader>ds',
        function()
          local widgets = require('dap.ui.widgets')
          widgets.centered_float(widgets.scopes)
        end,
        desc='dap ui widgets float center(scope)',
      },
      {'<Leader>dt', function () require("dapui").toggle() end, desc='dap ui toggle'},
    },
  },
  -- dap-virtual-text
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = "mfussenegger/nvim-dap",
    config = true,
  },
  -- dap java/typescript
  {
    "microsoft/vscode-js-debug",
    lazy = true,
    build = "npm install --legacy-peer-deps && npm run compile",
    version = 'v1.74.1'
  },
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = "mfussenegger/nvim-dap",
    ft = {
      "javascript",
      "typescript",
    },
    config = function()
      local lazy_path = os.getenv("HOME") .. "/.local/share/nvim/lazy"
      require("dap-vscode-js").setup({
        debugger_path = lazy_path .. "/vscode-js-debug",
        adapters = {
          "pwa-node",
          "pwa-chrome",
          "pwa-msedge",
          "node-terminal",
          "pwa-extensionHost",
        },
      })
      local dap = require('dap')
      for _, language in ipairs({ "typescript", "javascript" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch - node",
            program = "${file}",
            cwd = "${workspaceFolder}",
            port = 9229,
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            port = 9229,
          },
        }
      end
    end,
  },
  -- nvim-dap-go
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = "mfussenegger/nvim-dap",
    config = true,
    keys = {
      {'<leader>dg', function () require'dap-go'.debug_test() end, desc='test debug(go)'}
    },
  },
  -- nvim-dap-python
  {
    "mfussenegger/nvim-dap-python",
    dependencies = "mfussenegger/nvim-dap",
    ft = "python",
    config = function()
      local python_path = io.popen("which python3"):read("l")
      require("dap-python").setup(python_path)
    end,
    keys = {
      {'<leader>dc', function () require'dap-python'.test_class() end, desc='test class'},
      {'<leader>dd', '<ESC>:lua require("dap-python").debug_selection()<CR>', desc='python debug select'},
      {'<leader>dm', function () require'dap-python'.test_method() end, desc='test method'},
    }
  },
  -- nvim-dap-lua
  {
    "jbyuki/one-small-step-for-vimkind",
    dependencies = "mfussenegger/nvim-dap",
    ft = "lua",
    config = function()
      local dap = require("dap")
      dap.adapters.nlua = function(callback, config)
        if config.port ~= nil then
          callback({
            type = "server",
            host = config.host,
            port = config.port,
          })
        else
          require("osv").run_this()
        end
      end

      dap.configurations.lua = {
        {
          type = "nlua",
          request = "attach",
          name = "Attach to running Neovim instance",
          host = function()
            local value = vim.fn.input("Host [127.0.0.1]: ")
            if value ~= "" then
              return value
            end
            return "127.0.0.1"
          end,
          port = function()
            local val = tonumber(vim.fn.input("Port: "))
            return val
          end,
        },
      }
    end,
  },
  -- nvim-jdtls
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    keys = {
      {'<leader>dc', function () require'jdtls'.test_class() end, desc='test class'},
      {'<leader>dm', function () require'jdtls'.test_nearest_method() end, desc='test nearest method'},
    }
  },

  -- INFO: TOOL
  -- rust-tools
  {
    "simrat39/rust-tools.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    ft = "rust",
    config = {
      server = {
        standalone = true,
      },
      dap = {
        adapter = {
          type = "executable",
          command = "lldb-vscode",
          name = "rt_lldb",
        },
      },
    },
    keys = {
      {'<leader>rd', '<cmd>RustDebuggables<CR>', desc='rust debug'},
      {
        '<leader>rh',
        function ()
          require("rust-tools").hover_actions.hover_actions()
        end,
        desc='rust hover',
      },
      {'<leader>rr', '<cmd>RustRunnables<CR>', desc='rust run'},
    }
  },
  -- mason lsp
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "neovim/nvim-lspconfig",
    config = {
      ensure_installed = {
        "bashls",
        "dockerls",
        "docker_compose_language_service",
        "gradle_ls",
        "graphql",
        "gopls",
        "jdtls",
        "jsonls",
        "lua_ls",
        "pyright",
        "rust_analyzer",
        "taplo",
        "tsserver",
        "yamlls",
      },
      automatic_installation = true,
    },
  },
  -- comment
  {
    "numToStr/Comment.nvim",
    config = true,
  },
  -- surround
  {
    "kylechui/nvim-surround",
    config = true,
  },
  -- nvim tree
  {
    "kyazdani42/nvim-tree.lua",
    dependencies = {
      "kyazdani42/nvim-web-devicons",
    },
    config = {
      sync_root_with_cwd = true,
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
    },
    keys = {
      { '<localleader>l', '<cmd>NvimTreeToggle<CR>', desc='nvim tree' },
      { '<localleader>f', '<cmd>NvimTreeFindFile<CR>', desc='find files(nvim-tree)'},
    }
  },
  -- lualine
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "kyazdani42/nvim-web-devicons",
      "SmiteshP/nvim-navic",
    },
    config = function()
      local function navic_winbar()
        local navic = require("nvim-navic")
        if navic.is_available() then
          return "%#WinBarSeparator#" .. navic.get_location() .. "%#WinBarSeparator#"
        else
          return "%#WinBarSeparator#" .. "%#WinBarSeparator#"
        end
      end

      require("lualine").setup({
        options = {
          theme = "catppuccin",
          disabled_filetypes = {
            winbar = {
              "NvimTree",
              "dbout",
              "dbui",
              "notify",
              "packer",
              "startify",
            },
          },
        },
        winbar = {
          lualine_a = {
            {
              navic_winbar,
            },
          },
        },
        extensions = {
          "fugitive",
          "nvim-dap-ui",
          "nvim-tree",
          "toggleterm",
        },
      })
    end,
  },
  -- refactoring
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = {
      "go",
      "java",
      "javascript",
      "python",
      "typescript",
    },
    config = {
      prompt_func_return_type = {
        go = true,
        java = true,
        javascript = true,
        python = true,
        typescript = true,
      },
      prompt_func_param_type = {
        go = true,
        java = true,
        javascript = true,
        python = true,
        typescript = true,
      },
    },
    keys = {
      {
        '<leader>re',
        function () require('refactoring').refactor('Extract Function') end,
        desc='extract function',
        mode='v',
      },
      {
        '<leader>rf',
        function () require('refactoring').refactor('Extract Function To File') end,
        desc='extract function to file',
        mode='v',
      },
      {
        '<leader>ri',
        function () require('refactoring').refactor('Inline Variable') end,
        desc='inline variable',
        mode={'n','v'}
      },
      {
        '<leader>rv',
        function () require('refactoring').refactor('Extract Variable') end,
        desc='extract variable',
        mode='v',
      },
      {
        '<leader>rb',
        function () require('refactoring').refactor('Extract Block') end,
        desc='refactoring extract block',
      },
      {
        '<leader>rf',
        function () require('refactoring').refactor('Extract Block To File') end,
        desc= 'refactoring extract block to file',
      }
    }
  },
  -- auto pair
  {
    'windwp/nvim-autopairs',
    config = {},
  },
  -- cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "windwp/nvim-autopairs",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      local cmp = require("cmp")
      local navic = require("nvim-navic")
      local lspconfig = require("lspconfig")
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "neorg" },
          { name = "crates" },
          { name = 'vim-dadbod-completion' },
        }, {
          { name = "buffer" },
        }),
      })

      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )

      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
        }, {
          { name = "buffer" },
        }),
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      -- Setup lspconfig.
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local languages = {
        "bashls",
        "dockerls",
        "docker_compose_language_service",
        "gradle_ls",
        "graphql",
        "gopls",
        "jdtls",
        "jsonls",
        "lua_ls",
        "pyright",
        "rust_analyzer",
        "taplo",
        "tsserver",
        "yamlls",
      }

      for _, language in ipairs(languages) do
        if language == "lua_ls" then
          lspconfig[language].setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = {
                  globals = {
                    "vim",
                  },
                },
              },
            },
          })
        elseif language == "pyright" then
          lspconfig[language].setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              python = {
                analysis = {
                  diagnosticMode = "openFilesOnly",
                  typeCheckingMode = "off",
                },
              },
            },
          })
        else
          lspconfig[language].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end
      end
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = {"nvim-lua/plenary.nvim"},
    config = {}
  },
}
