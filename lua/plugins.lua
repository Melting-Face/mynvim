local servers = require("configs.lsp_servers")
local language_servers = servers.list()

local filetypes = {
  "c",
  "cpp",
  "rust",
  "lua",
  "python",
  "java",
  "javascript",
  "typescript",
}

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
  -- white space
  "ntpeters/vim-better-whitespace",
  --undotree
  {
    "mbbill/undotree",
    keys = {
      { "<localleader>u", "<cmd>UndotreeToggle<CR>", desc = "undo tree" },
    },
  },
  --todo
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  -- tmux
  {
    "aserowy/tmux.nvim",
    config = true,
  },
  -- HOP
  {
    "smoka7/hop.nvim",
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
  -- sed
  {
    "nvim-pack/nvim-spectre",
    config = true,
  },
  --telescope(fzf)
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    tag = "0.1.5",
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
  -- text case
  {
    "johmsalas/text-case.nvim",
    config = function()
      require("textcase").setup({})
    end,
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
      "nvim-telescope/telescope.nvim",
    },
    opts = {
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
    opts = {
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
    tag = "v2.1.0",
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
    -- configs/compilers API는 master 브랜치에만 있다 (main은 재작성됨)
    branch = "master",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
    -- 모든 파일에서 하이라이트와 텍스트 오브젝트가 동작하도록 파일을 열 때 로드한다
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      -- Windows에서는 MSVC 대신 zig/gcc/clang으로 파서를 컴파일한다
      if require("configs.paths").is_windows() then
        require("nvim-treesitter.install").compilers = { "zig", "gcc", "clang" }
      end
      require("nvim-treesitter.configs").setup({
        sync_install = false,
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
        ensure_installed = {
          "bash",
          "dockerfile",
          "java",
          "javascript",
          "json",
          "lua",
          "make",
          "markdown",
          "markdown_inline",
          "prisma",
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
            -- ]d/[d는 nvim 기본 진단 이동이므로 조건문 이동은 ]i/[i(if)를 쓴다
            goto_next = {
              ["]i"] = "@conditional.outer",
            },
            goto_previous = {
              ["[i"] = "@conditional.outer",
            },
          },
          swap = {
            enable = true,
            -- <leader>a는 Claude Code 키 그룹이므로 swap은 <leader>s(n/p)를 쓴다
            swap_next = {
              ["<leader>sn"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>sp"] = "@parameter.inner",
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
    opts = {
      enabled = true,
      snippet_engine = "luasnip",
    },
    keys = {
      { "<leader>nn", "<cmd>Neogen<CR>", desc = "Neogen" },
    },
  },
  -- for winbar
  {
    "SmiteshP/nvim-navic",
    dependencies = "neovim/nvim-lspconfig",
    lazy = true,
    opts = {
      highlight = true,
    },
  },
  -- NOTE: vim dadbod
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
    },
    keys = {
      { "<localleader>d", "<cmd>DBUIToggle<CR>",        desc = "db ui" },
      { "<leader>da",     "<cmd>DBUIAddConnection<CR>", desc = "add connection" },
    },
  },
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
          null_ls.builtins.code_actions.gitsigns,

          null_ls.builtins.diagnostics.sqruff,
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.yamllint,

          null_ls.builtins.formatting.sqruff,
          null_ls.builtins.formatting.prettierd,
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.xmllint,
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
    opts = {
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
    opts = {
      options = {
        separator_style = "padded_slant",
        numbers = function(opts)
          return string.format("%s·%s", opts.raise(opts.id), opts.lower(opts.ordinal))
        end,
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
  -- scope.nvim for tab
  {
    "tiagovla/scope.nvim",
    config = true,
  },

  -- INFO: DAP
  -- nvim-dap-ui
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    ft = filetypes,
    config = function()
      local dap = require("dap")

      local paths = require("configs.paths")

      dap.adapters.codelldb = {
        type = "executable",
        command = paths.exe(paths.mason_package("codelldb") .. "/codelldb"),
      }

      dap.configurations.rust = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.c = dap.configurations.rust
      dap.configurations.cpp = dap.configurations.rust
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
      {
        "<leader>b",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "toggle breakpoint",
      },
      {
        "<leader>B",
        function()
          require("dap").set_breakpoint()
        end,
        desc = "set breakpoint",
      },
      {
        "<Leader>lp",
        function()
          require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end,
        desc = "set breakpoint with message",
      },
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "dap run(continue)",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "dap step over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "dap step into",
      },
      {
        "<F12>",
        function()
          require("dap").step_out()
        end,
        desc = "dap step out",
      },
      {
        "<Leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "open repl",
      },
      {
        "<Leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "run last",
      },
      {
        "<Leader>dh",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "dap ui widgets",
        mode = { "n", "v" },
      },
      {
        "<Leader>dp",
        function()
          require("dap.ui.widgets").preview()
        end,
        desc = "dap ui preview",
        mode = { "n", "v" },
      },
      {
        "<Leader>df",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.frames)
        end,
        desc = "dap ui widgets float center(frame)",
      },
      {
        "<Leader>ds",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.scopes)
        end,
        desc = "dap ui widgets float center(scope)",
      },
      {
        "<Leader>dt",
        function()
          require("dapui").toggle()
        end,
        desc = "dap ui toggle",
      },
    },
  },
  -- dap-virtual-text
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = "mfussenegger/nvim-dap",
    config = true,
    ft = filetypes,
  },
  -- nvim-dap-python
  {
    "mfussenegger/nvim-dap-python",
    dependencies = "mfussenegger/nvim-dap",
    ft = "python",
    config = function()
      local py = require("configs.paths").python()
      if py ~= "" then
        -- debugpy가 설치되어 있을 때만 설정
        if vim.system({ py, "-c", "import debugpy" }):wait().code == 0 then
          require("dap-python").setup(py)
        end
      end
    end,
    keys = {
      {
        "<leader>dc",
        function()
          require("dap-python").test_class()
        end,
        desc = "test class",
      },
      { "<leader>dd", '<ESC>:lua require("dap-python").debug_selection()<CR>', desc = "python debug select" },
      {
        "<leader>dm",
        function()
          require("dap-python").test_method()
        end,
        desc = "test method",
      },
    },
  },
  -- nvim-jdtls
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    keys = {
      {
        "<leader>dc",
        function()
          require("jdtls").test_class()
        end,
        desc = "test class",
      },
      {
        "<leader>dm",
        function()
          require("jdtls").test_nearest_method()
        end,
        desc = "test nearest method",
      },
    },
  },
  -- mason lsp
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "SmiteshP/nvim-navic",
    },
    opts = {
      ensure_installed = language_servers,
      automatic_enable = {
        exclude = servers.automatic_enable_exclude,
      },
    },
    config = function(_, opts)
      -- 모든 서버에 nvim-cmp 자동완성 capabilities를 넘긴다
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
      for name, cfg in pairs(servers.settings) do
        vim.lsp.config(name, cfg)
      end
      -- winbar 위치 표시(navic)는 document symbol을 지원하는 서버에만 붙인다
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserNavic", {}),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, ev.buf)
          end
        end,
      })
      require("mason-lspconfig").setup(opts)
    end,
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
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      sync_root_with_cwd = true,
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
      git = {
        enable = false,
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
          theme = "auto",
          disabled_filetypes = {
            winbar = {
              "NvimTree",
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
        -- lualine_c는 기본값(파일명)을 그대로 두고, 오른쪽에 LSP 상태를 붙인다
        sections = { lualine_x = { "lsp_status", "encoding", "fileformat", "filetype" } },
        extensions = {
          "fugitive",
          "nvim-dap-ui",
          "nvim-tree",
        },
      })
    end,
  },
  -- refactoring
  -- {
  --   "ThePrimeagen/refactoring.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   ft = {
  --     "java",
  --     "javascript",
  --     "python",
  --     "typescript",
  --   },
  --   config = {
  --     prompt_func_return_type = {
  --       java = true,
  --       javascript = true,
  --       python = true,
  --       typescript = true,
  --     },
  --     prompt_func_param_type = {
  --       java = true,
  --       javascript = true,
  --       python = true,
  --       typescript = true,
  --     },
  --   },
  --   keys = {
  --     {
  --       "<leader>re",
  --       function()
  --         require("refactoring").refactor("Extract Function")
  --       end,
  --       desc = "extract function",
  --       mode = "v",
  --     },
  --     {
  --       "<leader>rf",
  --       function()
  --         require("refactoring").refactor("Extract Function To File")
  --       end,
  --       desc = "extract function to file",
  --       mode = "v",
  --     },
  --     {
  --       "<leader>ri",
  --       function()
  --         require("refactoring").refactor("Inline Variable")
  --       end,
  --       desc = "inline variable",
  --       mode = { "n", "v" },
  --     },
  --     {
  --       "<leader>rv",
  --       function()
  --         require("refactoring").refactor("Extract Variable")
  --       end,
  --       desc = "extract variable",
  --       mode = "v",
  --     },
  --     {
  --       "<leader>rb",
  --       function()
  --         require("refactoring").refactor("Extract Block")
  --       end,
  --       desc = "refactoring extract block",
  --     },
  --     {
  --       "<leader>rf",
  --       function()
  --         require("refactoring").refactor("Extract Block To File")
  --       end,
  --       desc = "refactoring extract block to file",
  --     },
  --   },
  -- },
  -- rust-tools
  {
    "mrcjkb/rustaceanvim",
    version = "^6", -- Recommended
    lazy = false, -- This plugin is already lazy
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
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      local cmp = require("cmp")

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
          { name = "vim-dadbod-completion" },
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
    end,
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>a",  nil,                              desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
    },
  },
}
