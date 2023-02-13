return {
  -- devicons
  "kyazdani42/nvim-web-devicons",
  -- multi cursor
  "mg979/vim-visual-multi",
  -- async
  "nvim-lua/plenary.nvim",
  -- cache
  "lewis6991/impatient.nvim",
  -- tabular
  "godlygeek/tabular",
  -- whitespace
  "ntpeters/vim-better-whitespace",
  -- ctags
  "preservim/tagbar",
  -- minimap
  "wfxr/minimap.vim",
  -- startify
  'mhinz/vim-startify',

  --telescope(fzf)
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-dap.nvim',
      'debugloop/telescope-undo.nvim',
    },
    config = function ()
      local telescope = require('telescope')
      telescope.setup {}
      telescope.load_extension("undo")
      telescope.load_extension('dap')
    end
  },

  -- CSV
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

  -- GIT
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
  },
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
    config = function ()
      require('bqf').setup{}
    end
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
    'folke/tokyonight.nvim',
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
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
          "c",
          "cmake",
          "cpp",
          "dockerfile",
          "go",
          "html",
          "http",
          "java",
          "javascript",
          "json",
          "lua",
          "make",
          "markdown",
          "norg",
          "python",
          "regex",
          "rust",
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
          lsp_interop = {
            enable = true,
            border = "none",
            floating_preview_opts = {},
            peek_definition_code = {
              ["<leader>df"] = "@function.outer",
              ["<leader>dF"] = "@class.outer",
            },
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
  -- neotest
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "haydenmeade/neotest-jest",
      "nvim-neotest/neotest-vim-test",
      "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require('neotest-vim-test')({
            ignore_filetypes = {
              "lua",
              "javascript",
              "python",
              "typescript",
            }
          }),
          require("neotest-jest"),
          require("neotest-plenary"),
          require("neotest-python")({
            dap = { justMyCode = false },
          }),
        },
      })
    end,
  },
  -- neodev
  {
    "folke/neodev.nvim",
    config = {
      library = {
        plugins = {
          "neotest",
        },
        types = true,
      },
    },
  },
  -- luapad
  {
    "rafcamlet/nvim-luapad",
    ft = "lua",
    config = true,
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
        javacriptreact = "jsdoc",
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
        snippet_engine = "luasnip",
        languages = languages,
      })
    end,
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
  },
  -- null_ls
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = {
      "BufRead",
      "BufWrite",
    },
    lazy = true,
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        diagnostics_format = "[#{c}] #{m} (#{s})",
        debounce = 250,
        sources = {
          null_ls.builtins.diagnostics.eslint_d,
          null_ls.builtins.diagnostics.flake8,
          null_ls.builtins.diagnostics.golangci_lint,
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.luacheck,
          null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.diagnostics.yamllint,

          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.dart_format,
          null_ls.builtins.formatting.eslint_d,
          null_ls.builtins.formatting.isort,
          null_ls.builtins.formatting.rustfmt,
          null_ls.builtins.formatting.shfmt,
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.taplo,
          null_ls.builtins.formatting.yamlfmt,
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  -- todo comment
  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
  },
  -- trouble
  {
    "folke/trouble.nvim",
    dependencies = "kyazdani42/nvim-web-devicons",
    config = {
      mode = "document_diagnostics",
    },
  },
  -- autopairs
  {
    "windwp/nvim-autopairs",
    config = {
      disable_filetype = {
        "TelescopePrompt",
        "vim",
      },
    },
  },
  -- markdown
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    setup = function()
      vim.g.mkdp_filetypes = {
        "markdown",
      }
    end,
    ft = {
      "markdown",
    },
  },
  -- whici keys
  {
    "folke/which-key.nvim",
    lazy = true,
    config = true,
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
    dependencies = "kyazdani42/nvim-web-devicons",
    config = {
      options = {
        separator_style = "padded_slant",
        numbers = function(opts)
          return string.format("%s·%s", opts.raise(opts.id), opts.lower(opts.ordinal))
        end,
        diagnostics = "nvim_lsp",
      },
    },
  },
  -- scope.nvim for tab
  {
    "tiagovla/scope.nvim",
    config = true,
  },

  -- DAP
  -- dap java/typescript
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = "mfussenegger/nvim-dap",
    ft = {
      "javascript",
      "typescript",
    },
    config = function()
      local package_path = os.getenv("HOME") .. "/.local/share/nvim/mason/packages"
      require("dap-vscode-js").setup({
        debugger_path = package_path .. "/js-debug-adapter",
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
  },
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
  },
  -- flutter-tools
  {
    'akinsho/flutter-tools.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = {}
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
  -- nvim-dap-ui
  {
    "rcarriga/nvim-dap-ui",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup({})
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
  },
  -- dap-virtual-text
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = "mfussenegger/nvim-dap",
    config = true,
  },
  -- mason
  {
    "williamboman/mason.nvim",
    dependencies = "williamboman/mason-lspconfig.nvim",
    config = true,
  },
  -- mason lsp
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "neovim/nvim-lspconfig",
    event = "BufRead",
    config = {
      ensure_installed = {
        "bashls",
        "clangd",
        "dockerls",
        "gopls",
        "jdtls",
        "jsonls",
        "lua_ls",
        "pyright",
        "rust_analyzer",
        "sqlls",
        "taplo",
        "tsserver",
        "yamlls",
      },
      automatic_installation = true,
    },
  },
  -- nvim-jdtls
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },
  -- mason null-ls
  {
    "jayp0521/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    lazy = true,
    config = {
      ensure_installed = {
        "black",
        "eslint_d",
        "dart_format",
        "flake8",
        "golangci_lint",
        "hadolint",
        "isort",
        "jq",
        "luacheck",
        "remark",
        "rustfmt",
        "shellcheck",
        "shfmt",
        "stylua",
        "yamlfmt",
        "yamllint",
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
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
    },
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
          theme = "tokyonight",
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
    },
    lazy = true,
    event = {
      "BufRead",
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
          { name = "neorg" },
          { name = "crates" },
        }, {
          { name = "buffer" },
        }),
      })

      -- Set configuration for specific filetype.
      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
        }, {
          { name = "buffer" },
        }),
      })

      -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
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
        "clangd",
        "dockerls",
        "gopls",
        "jdtls",
        "jsonls",
        "lua_ls",
        "pyright",
        "rust_analyzer",
        "sqlls",
        "taplo",
        "tsserver",
        "yamlls",
      }

      for _, language in ipairs(languages) do
        if language == "sumneko_lua" then
          lspconfig[language].setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              Lua = {
                completion = {
                  callSnippet = "Replace",
                },
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
  -- neorg
  {
    "nvim-neorg/neorg",
    dependencies = {
      "nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "nvim-neorg/neorg-telescope",
    },
    ft = "norg",
    build = ":Neorg sync-parsers",
    config = {
      load = {
        ["core.defaults"] = {},
        ["core.norg.concealer"] = {},
        ["core.norg.completion"] = {
          config = {
            engine = "nvim-cmp",
          },
        },
        ["core.export"] = {},
        ["core.integrations.telescope"] = {},
      },
    },
  },
  -- toggleterm
  {
    "akinsho/toggleterm.nvim",
    config = true,
  },
}
