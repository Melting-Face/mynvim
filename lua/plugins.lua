return {
  -- devicons
  "nvim-tree/nvim-web-devicons",
  -- async
  "nvim-lua/plenary.nvim",
  -- tabular
  "godlygeek/tabular",
  -- startify
  "mhinz/vim-startify",
  -- multi cursor
  "mg979/vim-visual-multi",
  -- vim move
  -- {
  --   "matze/vim-move",
  --   keys = {
  --     { "∆", "<Plug>MoveLineDown", mode = { "n" } },
  --     { "˚", "<Plug>MoveLineUp", mode = { "n" } },
  --     { "˙", "<Plug>MoveCharLeft", mode = { "n" } },
  --     { "¬", "<Plug>MoveCharRight", mode = { "n" } },
  --     { "∆", "<Plug>MoveBlockDown", mode = { "v" } },
  --     { "˚", "<Plug>MoveBlockUp", mode = { "v" } },
  --     { "˙", "<Plug>MoveBlockLeft", mode = { "v" } },
  --     { "¬", "<Plug>MoveBlockRight", mode = { "v" } },
  --   },
  -- },
  --undotree
  {
    "mbbill/undotree",
    keys = {
      { "<localleader>u", "<cmd>UndotreeToggle<CR>", desc = "undo tree" },
    },
  },
  -- tmux
  {
    "aserowy/tmux.nvim",
    config = true,
  },
  -- HOP
  {
    "phaazon/hop.nvim",
    config = true,
    keys = {
      {
        "f",
        function()
          require("hop").hint_char1()
        end,
        desc = "hop 1",
        mode = { "n", "v" },
      },
      {
        "F",
        function()
          require("hop").hint_char2()
        end,
        desc = "hop 2",
        mode = { "n", "v" },
      },
    },
  },

  --telescope(fzf)
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    config = true,
    keys = {
      { "<leader>ff",  ":Telescope find_files<CR>",   desc = "find files" },
      { "<leader>fgc", ":Telescope git_bcommits<CR>", desc = "git commit log (buffer)" },
      { "<leader>fgt", ":Telescope git_commits<CR>",  desc = "git commit log (project)" },
      { "<leader>fk",  ":Telescope keymaps<cr>",      desc = "keymaps" },
      { "<leader>fq",  ":Telescope quickfix<cr>",     desc = "quickfix" },
      { "<leader>fr",  ":Telescope registers<cr>",    desc = "registers" },
      { "<leader>fs",  ":Telescope live_grep<CR>",    desc = "search" },
    },
  },

  -- INFO: CSV
  {
    "mechatroner/rainbow_csv",
    ft = "csv",
  },
  {
    "chrisbra/csv.vim",
    ft = "csv",
  },

  -- INFO: GIT
  -- vim-fugitive
  "tpope/vim-fugitive",
  -- neogit
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    config = {
      integrations = {
        diffview = true,
      },
      signs = {
        section = { "*", "=" },
        item = { "*", "=" },
        hunk = { "", "" },
      },
    },
    keys = {
      { "<leader>ng", "<cmd>Neogit<CR>", desc = "neogit" },
    },
  },
  -- gitsigns
  {
    "lewis6991/gitsigns.nvim",
    config = {
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        ignore_whitespace = false,
      },
    },
    event = "BufRead",
    keys = {
      { "<leader>hb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "curret line blame" },
      { "<leader>hd", "<cmd>Gitsigns toggle_deleted<cr>",            desc = "deleted" },
      { "<leader>ht", "<cmd>Gitsigns diffthis<cr>",                  desc = "diff this" },
      { "[h",         "<cmd>Gitsigns prev_hunk<cr>",                 desc = "prev hunk" },
      { "]h",         "<cmd>Gitsigns next_hunk<cr>",                 desc = "next hunk" },
    },
  },
  -- git congflict
  {
    "akinsho/git-conflict.nvim",
    config = true,
  },
  {
    "https://gitlab.com/yorickpeterse/nvim-pqf.git",
    config = function()
      require("pqf").setup()
    end,
  },

  -- quick fix
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function()
      require("bqf").setup({})
    end,
  },
  -- notify
  -- {
  --   "rcarriga/nvim-notify",
  --   config = function()
  --     vim.notify = require("notify")
  --   end,
  -- },
  -- theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  -- nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    lazy = true,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        sync_install = true,
        indent = {
          enable = true,
        },
        ensure_installed = {
          "bash",
          "dockerfile",
          -- "java",
          "javascript",
          "json",
          "lua",
          "make",
          "markdown",
          "markdown_inline",
          "python",
          "sql",
          "regex",
          "toml",
          "typescript",
          "yaml",
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
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
              ["]]"] = { query = "@class.outer", desc = "Next class start" },
              ["]o"] = "@loop.*",
              ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
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
            goto_next = {
              ["]d"] = "@conditional.outer",
            },
            goto_previous = {
              ["[d"] = "@conditional.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>A"] = "@parameter.inner",
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
      "lua",
      "java",
      "javascript",
      "javascriptreact",
      "python",
      "sh",
      "typescript",
      "typescriptreact",
    },
    config = function()
      local lang_doc_map = {
        lua = "ldoc",
        java = "javadoc",
        javascript = "jsdoc",
        javascriptreact = "jsdoc",
        python = "google_docstrings",
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
      { "<leader>nn", "<cmd>Neogen<CR>", desc = "Neogen" },
    },
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
  -- NOTE: vim dadbod
  -- {
  --   "kristijanhusak/vim-dadbod-ui",
  --   dependencies = {
  --     "tpope/vim-dadbod",
  --   },
  --   keys = {
  --     { "<localleader>d", "<cmd>DBUIToggle<CR>",        desc = "db ui" },
  --     { "<leader>da",     "<cmd>DBUIAddConnection<CR>", desc = "add connection" },
  --   },
  -- },
  -- mason
  {
    "williamboman/mason.nvim",
    config = true,
  },
  -- null_ls
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        diagnostics_format = "[#{c}] #{m} (#{s})",
        sources = {
          null_ls.builtins.diagnostics.eslint_d,
          null_ls.builtins.diagnostics.ruff.with({
            extra_args = {
              "--extend-select",
              "I,C4,C90,COM,SIM,PD",
              "--extend-ignore",
              "PD901",
            },
          }),
          null_ls.builtins.diagnostics.sqlfluff.with({
            extra_args = { "--dialect", "snowflake" },
          }),
          null_ls.builtins.diagnostics.luacheck,
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.diagnostics.yamllint,

          null_ls.builtins.formatting.ruff.with({
            extra_args = {
              "--extend-select",
              "I,C4,C90,COM,SIM,PD",
              "--extend-ignore",
              "PD901",
            },
          }),
          null_ls.builtins.formatting.ruff_format,
          null_ls.builtins.formatting.sqlfluff.with({
            extra_args = { "--dialect", "snowflake" },
          }),
          null_ls.builtins.formatting.eslint_d,
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.taplo,
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<space>f",
        function()
          vim.lsp.buf.format({ async = true })
        end,
        desc = "LSP format",
      },
    },
  },
  -- mason null-ls
  {
    "jayp0521/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = {
      automatic_installation = true,
    },
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
    main = "ibl",
    config = function()
      local highlight = {
        "CursorColumn",
        "Whitespace",
      }
      require("ibl").setup({
        indent = { highlight = highlight, char = "" },
        whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
      })
    end,
  },
  -- bufferline
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    config = {
      options = {
        separator_style = "padded_slant",
        numbers = function(opts)
          return string.format("%s·%s", opts.raise(opts.id), opts.lower(opts.ordinal))
        end,
        diagnostics = "nvim_lsp",
        buffer_close_icon = "",
      },
    },
    keys = {
      { "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "goto buffer 1" },
      { "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "goto buffer 2" },
      { "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "goto buffer 3" },
      { "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "goto buffer 4" },
      { "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "goto buffer 5" },
      { "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "goto buffer 6" },
      { "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "goto buffer 7" },
      { "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "goto buffer 8" },
      { "<leader>9", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "goto buffer 9" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    keys = {
      { "gD",       vim.lsp.buf.declaration,     desc = "goto declareation(lsp)" },
      { "gd",       vim.lsp.buf.definition,      desc = "goto definition(lsp)" },
      { "K",        vim.lsp.buf.hover,           desc = "hover(lsp)" },
      { "gi",       vim.lsp.buf.implementation,  desc = "implementation(lsp)" },
      { "<space>D", vim.lsp.buf.type_definition, desc = "type definition(lsp)" },
      { "<space>q", vim.diagnostic.setloclist,   desc = "setloclist(lsp)" },
      { "gr",       vim.lsp.buf.references,      desc = "references(lsp)" },
      {
        "<leader>ca",
        "<cmd>Lspsaga code_action<CR>",
        desc = "code action",
        mode = { "n", "v" },
      },
      { "K", vim.lsp.buf.hover, desc = "hover doc" },
    },
  },
  -- scope.nvim for tab
  {
    "tiagovla/scope.nvim",
    config = true,
  },

  -- INFO: DAP
  -- nvim-dap-ui
  -- {
  --   "rcarriga/nvim-dap-ui",
  --   dependencies = "mfussenegger/nvim-dap",
  --   ft = {
  --     "lua",
  --     "python",
  --     "java",
  --     "javascript",
  --     "typescript",
  --   },
  --   config = function()
  --     local dap = require("dap")
  --     local dapui = require("dapui")
  --     dapui.setup()
  --     dap.listeners.after.event_initialized["dapui_config"] = function()
  --       dapui.open()
  --     end
  --     dap.listeners.before.event_terminated["dapui_config"] = function()
  --       dapui.close()
  --     end
  --     dap.listeners.before.event_exited["dapui_config"] = function()
  --       dapui.close()
  --     end
  --   end,
  --   keys = {
  --     {
  --       "<leader>b",
  --       function()
  --         require("dap").toggle_breakpoint()
  --       end,
  --       desc = "toggle breakpoint",
  --     },
  --     {
  --       "<leader>B",
  --       function()
  --         require("dap").set_breakpoint()
  --       end,
  --       desc = "set breakpoint",
  --     },
  --     {
  --       "<Leader>lp",
  --       function()
  --         require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
  --       end,
  --       desc = "set breakpoint with message",
  --     },
  --     {
  --       "<F5>",
  --       function()
  --         require("dap").continue()
  --       end,
  --       desc = "dap run(continue)",
  --     },
  --     {
  --       "<F10>",
  --       function()
  --         require("dap").step_over()
  --       end,
  --       desc = "dap step over",
  --     },
  --     {
  --       "<F11>",
  --       function()
  --         require("dap").step_into()
  --       end,
  --       desc = "dap step into",
  --     },
  --     {
  --       "<F12>",
  --       function()
  --         require("dap").step_out()
  --       end,
  --       desc = "dap step out",
  --     },
  --     {
  --       "<Leader>dr",
  --       function()
  --         require("dap").repl.open()
  --       end,
  --       desc = "open repl",
  --     },
  --     {
  --       "<Leader>dl",
  --       function()
  --         require("dap").run_last()
  --       end,
  --       desc = "run last",
  --     },
  --     {
  --       "<Leader>dh",
  --       function()
  --         require("dap.ui.widgets").hover()
  --       end,
  --       desc = "dap ui widgets",
  --       mode = { "n", "v" },
  --     },
  --     {
  --       "<Leader>dp",
  --       function()
  --         require("dap.ui.widgets").preview()
  --       end,
  --       desc = "dap ui preview",
  --       mode = { "n", "v" },
  --     },
  --     {
  --       "<Leader>df",
  --       function()
  --         local widgets = require("dap.ui.widgets")
  --         widgets.centered_float(widgets.frames)
  --       end,
  --       desc = "dap ui widgets float center(frame)",
  --     },
  --     {
  --       "<Leader>ds",
  --       function()
  --         local widgets = require("dap.ui.widgets")
  --         widgets.centered_float(widgets.scopes)
  --       end,
  --       desc = "dap ui widgets float center(scope)",
  --     },
  --     {
  --       "<Leader>dt",
  --       function()
  --         require("dapui").toggle()
  --       end,
  --       desc = "dap ui toggle",
  --     },
  --   },
  -- },
  -- dap-virtual-text
  -- {
  --   "theHamsta/nvim-dap-virtual-text",
  --   dependencies = "mfussenegger/nvim-dap",
  --   config = true,
  --   ft = {
  --     "lua",
  --     "python",
  --     "java",
  --     "javascript",
  --     "typescript",
  --   },
  -- },
  -- nvim-dap-python
  -- {
  --   "mfussenegger/nvim-dap-python",
  --   dependencies = "mfussenegger/nvim-dap",
  --   ft = "python",
  --   config = function()
  --     local python_path = io.popen("which python3"):read("l")
  --     if python_path ~= nil then
  --       local debugpy = io.popen("pip list | grep debugpy"):read("l")
  --       if debugpy ~= nil then
  --         require("dap-python").setup(python_path)
  --       end
  --     end
  --   end,
  --   keys = {
  --     {
  --       "<leader>dc",
  --       function()
  --         require("dap-python").test_class()
  --       end,
  --       desc = "test class",
  --     },
  --     { "<leader>dd", '<ESC>:lua require("dap-python").debug_selection()<CR>', desc = "python debug select" },
  --     {
  --       "<leader>dm",
  --       function()
  --         require("dap-python").test_method()
  --       end,
  --       desc = "test method",
  --     },
  --   },
  -- },
  -- nvim-jdtls
  -- {
  --   "mfussenegger/nvim-jdtls",
  --   ft = "java",
  --   keys = {
  --     {
  --       "<leader>dc",
  --       function()
  --         require("jdtls").test_class()
  --       end,
  --       desc = "test class",
  --     },
  --     {
  --       "<leader>dm",
  --       function()
  --         require("jdtls").test_nearest_method()
  --       end,
  --       desc = "test nearest method",
  --     },
  --   },
  -- },
  -- mason lsp
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "neovim/nvim-lspconfig",
    config = {
      ensure_installed = {
        "bashls",
        "dockerls",
        "docker_compose_language_service",
        -- "gradle_ls",
        -- "jdtls",
        "jsonls",
        "lua_ls",
        "pyright",
        -- "rust_analyzer",
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
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = {
      sync_root_with_cwd = true,
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
    },
    keys = {
      { "<localleader>n", "<cmd>NvimTreeToggle<CR>",   desc = "nvim tree" },
      { "<leader>nf",     "<cmd>NvimTreeFindFile<CR>", desc = "find files(nvim-tree)" },
    },
  },
  -- lualine
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
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
      "java",
      "javascript",
      "python",
      "typescript",
    },
    config = {
      prompt_func_return_type = {
        java = true,
        javascript = true,
        python = true,
        typescript = true,
      },
      prompt_func_param_type = {
        java = true,
        javascript = true,
        python = true,
        typescript = true,
      },
    },
    keys = {
      {
        "<leader>re",
        function()
          require("refactoring").refactor("Extract Function")
        end,
        desc = "extract function",
        mode = "v",
      },
      {
        "<leader>rf",
        function()
          require("refactoring").refactor("Extract Function To File")
        end,
        desc = "extract function to file",
        mode = "v",
      },
      {
        "<leader>ri",
        function()
          require("refactoring").refactor("Inline Variable")
        end,
        desc = "inline variable",
        mode = { "n", "v" },
      },
      {
        "<leader>rv",
        function()
          require("refactoring").refactor("Extract Variable")
        end,
        desc = "extract variable",
        mode = "v",
      },
      {
        "<leader>rb",
        function()
          require("refactoring").refactor("Extract Block")
        end,
        desc = "refactoring extract block",
      },
      {
        "<leader>rf",
        function()
          require("refactoring").refactor("Extract Block To File")
        end,
        desc = "refactoring extract block to file",
      },
    },
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
      -- "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      local cmp = require("cmp")
      local navic = require("nvim-navic")
      local lspconfig = require("lspconfig")
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
          { name = "crates" },
          -- { name = "vim-dadbod-completion" },
        }, {
          { name = "buffer" },
        }),
      })

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
        -- "gradle_ls",
        -- "jdtls",
        "jsonls",
        "lua_ls",
        "pyright",
        -- "rust_analyzer",
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
}
