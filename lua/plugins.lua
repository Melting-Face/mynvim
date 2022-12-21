vim.cmd [[packadd packer.nvim]]

local packer = require('packer')

-- INFO: add max jobs
packer.init {
  max_jobs = 50,
}

return packer.startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  -- devicons
  use 'kyazdani42/nvim-web-devicons'
  -- multi cursor
  use 'mg979/vim-visual-multi'
  -- theme tokyonight
  use 'folke/tokyonight.nvim'
  -- async
  use 'nvim-lua/plenary.nvim'
  -- vim-fugitive
  use 'tpope/vim-fugitive'
  -- notify
  use 'rcarriga/nvim-notify'
  -- emmet
  use 'mattn/emmet-vim'
  -- rainbow csv
  use 'mechatroner/rainbow_csv'
  -- starttime
  use 'dstein64/vim-startuptime'
  -- cache
  use 'lewis6991/impatient.nvim'
  -- tabular
  use 'godlygeek/tabular'
  -- whitespace
  use 'ntpeters/vim-better-whitespace'
  -- outline
  use {
    'simrat39/symbols-outline.nvim',
    config = function ()
      require("symbols-outline").setup()
    end
  }
  -- minimap
  use 'wfxr/minimap.vim'
  -- java/typescript
  use {
    'mxsdev/nvim-dap-vscode-js',
    requires = {
      'mfussenegger/nvim-dap',
    }
  }
  -- jester
  use {
    'David-Kunz/jester',
    config = function ()
      require('jester').setup({})
    end
  }
  -- neodev
  use {
    'folke/neodev.nvim',
    config = function ()
      require('neodev').setup ()
    end
  }
  -- luapad
  use {
    'rafcamlet/nvim-luapad',
    config = function ()
      require('luapad').setup()
    end
  }
  -- neogen
  use {
    'danymat/neogen',
    requires = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      local lang_doc_map = {
        go = 'godoc',
        lua = 'ldoc',
        java ='javadoc',
        javascript = 'jsdoc',
        python = 'google_docstrings',
        rust = 'rustdoc',
        sh = 'google_bash',
        typescript = 'tsdoc',
        typescriptreact = 'tsdoc',
      }

      local languages = {}

      for lang, doc in ipairs(lang_doc_map) do
        languages[lang]['template']['annotation_convention'] = doc
      end

      require('neogen').setup({
        snippet_engine = 'luasnip',
        languages = languages,
      })
    end,
  }
  -- for winbar
  use {
    'SmiteshP/nvim-navic',
    requires = 'neovim/nvim-lspconfig',
    config = function ()
      require('nvim-navic').setup {
        highlight = true,
      }
    end
  }
  -- magma
  use {
    'dccsillag/magma-nvim',
    run = ':UpdateRemotePlugins',
  }
  -- vim dadbod
  use {
    'kristijanhusak/vim-dadbod-ui',
    requires = {
      'tpope/vim-dadbod',
    }
  }
  -- crates
  use {
    'saecki/crates.nvim',
    event = {
      'BufRead Cargo.toml'
    },
    requires = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('crates').setup()
    end,
  }
  -- noice
  use {
    'folke/noice.nvim',
    config = function()
      require('noice').setup()
    end,
    requires = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    }
  }
  -- restnvim
  use {
    'rest-nvim/rest.nvim',
    ft = 'http',
    requires = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('rest-nvim').setup({
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
            json = 'jq',
            html = function(body)
              return vim.fn.system({'tidy', '-i', '-q', '-'}, body)
            end
          },
        },
        -- Jump to request line on run
        jump_to_request = false,
        env_file = '.env',
        custom_dynamic_variables = {},
        yank_dry_run = true,
      })
    end
  }
  -- null_ls
  use({
    'jose-elias-alvarez/null-ls.nvim',
    config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        diagnostics_format = '[#{c}] #{m} (#{s})',
        debounce = 750,
        sources = {
          null_ls.builtins.diagnostics.eslint_d,
          null_ls.builtins.diagnostics.flake8,
          null_ls.builtins.diagnostics.golangci_lint,
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.luacheck,
          null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.diagnostics.yamllint,

          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.eslint_d,
          null_ls.builtins.formatting.isort,
          null_ls.builtins.formatting.remark,
          null_ls.builtins.formatting.rustfmt,
          null_ls.builtins.formatting.shellharden,
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.yamlfmt,
        },
      })
    end,
    requires = {
      'nvim-lua/plenary.nvim',
    },
  })
  -- todo comment
  use {
    'folke/todo-comments.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('todo-comments').setup ()
    end
  }
  -- trouble
  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require'trouble'.setup ({
        mode = 'document_diagnostics'
      })
    end
  }
  -- autopairs
  use {
	  'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup ({
        disable_filetype = {
          'TelescopePrompt',
          'vim',
        },
      })
    end
  }
  -- markdown
  use({
    'iamcco/markdown-preview.nvim',
    run = 'cd app && npm install',
    setup = function()
      vim.g.mkdp_filetypes = {
        'markdown'
      }
    end,
    ft = {
      'markdown'
    },
  })
  -- whici keys
  use {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup ()
    end
  }
  -- indent-blankline
  use {
    'lukas-reineke/indent-blankline.nvim',
    config = function ()
      require('indent_blankline').setup {
        show_current_context = true,
        show_current_context_start = true,
        show_end_of_line = true,
      }
    end
  }
  -- bufferline
  use {
    'akinsho/bufferline.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function ()
      require('bufferline').setup {
        options = {
          separator_style = 'padded_slant',
          numbers = function(opts)
            return string.format('%s·%s', opts.raise(opts.id), opts.lower(opts.ordinal))
          end,
          diagnostics = 'nvim_lsp',
        },
      }
    end
  }
  -- scope.nvim for tab
  use {
    'tiagovla/scope.nvim',
    config = function ()
      require('scope').setup ()
    end
  }
  -- nvim-jdtls
  use {
    'mfussenegger/nvim-jdtls',
    ft = {
      'java'
    },
  }
  -- nvim-dap-go
  use {
    'leoluz/nvim-dap-go',
    requires = {
      'mfussenegger/nvim-dap'
    },
    config = function ()
      require('dap-go').setup ()
    end,
  }
  -- nvim-dap-python
  use {
    'mfussenegger/nvim-dap-python',
    requires = {
      'mfussenegger/nvim-dap'
    },
  }
  -- rust-tools
  use {
    'simrat39/rust-tools.nvim',
    requires = {
      'neovim/nvim-lspconfig',
      'nvim-lua/plenary.nvim',
      'mfussenegger/nvim-dap',
    },
    config = function ()
      local opt = {
        server = {
          standalone = true,
        },
        dap = {
          adapter = {
            type = 'executable',
            command = 'lldb-vscode',
            name = 'rt_lldb',
          },
        },
      }
      require('rust-tools').setup (opt)
    end
  }
  -- nvim-dap-lua
  use {
    'jbyuki/one-small-step-for-vimkind',
    requires = {
      'mfussenegger/nvim-dap'
    },
  }
  -- nvim-dap-ui
  use {
    'rcarriga/nvim-dap-ui',
    requires = {
      'mfussenegger/nvim-dap'
    },
    config = function ()
      require'dapui'.setup ()
    end
  }
  use {
    'theHamsta/nvim-dap-virtual-text',
    requires = {
      'mfussenegger/nvim-dap'
    },
    config = function ()
      require'nvim-dap-virtual-text'.setup ()
    end
  }
  -- lsp installer
  use {
    'williamboman/mason-lspconfig.nvim',
    requires = { 'neovim/nvim-lspconfig' },
    config = function()
      require'mason-lspconfig'.setup({
        ensure_installed = {
          'bashls',
          'dockerls',
          'gopls',
          'jdtls',
          'jsonls',
          'pyright',
          'rust_analyzer',
          'sumneko_lua',
          'sqlls',
          'tsserver',
          'vimls',
          'yamlls',
        },
        automatic_installation = true,
      })
    end
  }
  use {
    'williamboman/mason.nvim',
    requires = {
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require'mason'.setup()
    end
  }
  -- alpha
  use {
    'goolord/alpha-nvim',
    requires = {
      'kyazdani42/nvim-web-devicons'
    },
    config = function ()
      require'alpha'.setup(require'alpha.themes.dashboard'.config)
    end
  }
  -- comment
  use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup ()
    end
  }
  -- surround
  use {
      'kylechui/nvim-surround',
      tag = '*',
      config = function()
          require('nvim-surround').setup ()
      end
  }
  -- nvim tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
      require'nvim-tree'.setup ()
    end
  }
  -- project nvim
  use {
    'ahmedkhalf/project.nvim',
    config = function()
      require('project_nvim').setup ()
    end
  }
  -- lualine
  use {
    'nvim-lualine/lualine.nvim',
    requires = {
      'kyazdani42/nvim-web-devicons',
      opt = true
    },
    after = 'nvim-navic',
    config = function()
      local function navic_winbar ()
        local navic = require'nvim-navic'
        if navic.is_available() then
          return '%#WinBarSeparator#' .. navic.get_location() .. '%#WinBarSeparator#'
        else
          return '%#WinBarSeparator#' .. '%#WinBarSeparator#'
        end
      end
      require'lualine'.setup {
        options = {
          theme = 'palenight',
          disabled_filetypes = {
            winbar = {
              'alpha',
              'dbui',
              'dbout',
              'NvimTree',
              'packer',
            }
          }
        },
        winbar = {
          lualine_a = {
            {
              navic_winbar,
            }
          }
        },
        extensions = {
          'fugitive',
          'nvim-dap-ui',
          'nvim-tree',
          'toggleterm',
        }
      }
    end
  }
  -- nvim-treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'RRethy/nvim-treesitter-textsubjects',
      'nvim-treesitter/nvim-treesitter-textobjects',
      'windwp/nvim-ts-autotag',
      'nvim-treesitter/nvim-treesitter-context',
      'nvim-treesitter/playground',
    },
    run = ':TSUpdate',
    config = function ()
      require'nvim-treesitter.install'.compilers = { 'gcc-12' }
      require'nvim-treesitter.configs'.setup {
        sync_install = true,
        ensure_installed = {
          'bash',
          'dockerfile',
          'go',
          'html',
          'http',
          'java',
          'javascript',
          'json',
          'lua',
          'markdown',
          'norg',
          'python',
          'regex',
          'rust',
          'sql',
          'tsx',
          'typescript',
          'vim',
          'yaml',
        },
        autotag = {
          enable = true,
        },
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
          },
        },
        textsubjects = {
          enable = true,
          keymaps = {
              ['.'] = 'textsubjects-smart',
              [';'] = 'textsubjects-container-outer',
              ['i;'] = 'textsubjects-container-inner',
          }
        },
        textobjects = {
          select = {
              enable = true,
              lookahead = true,
              keymaps = {
                  ['af'] = '@function.outer',
                  ['if'] = '@function.inner',
                  ['ac'] = '@class.outer',
                  ['ic'] = '@class.inner'
              }
          },
          move = {
              enable = true,
              set_jumps = true,
              goto_next_start = {
                  [']m'] = '@function.outer',
                  [']]'] = '@class.outer'
              },
              goto_next_end = {
                  [']M'] = '@function.outer',
                  [']['] = '@class.outer'
              },
              goto_previous_start = {
                  ['[m'] = '@function.outer',
                  ['[['] = '@class.outer'
              },
              goto_previous_end = {
                  ['[M'] = '@function.outer',
                  ['[]'] = '@class.outer'
              }
          }
        },
      }
    end
  }
  use {
    'ThePrimeagen/refactoring.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function ()
      require('refactoring').setup()
    end
  }
  -- cmp
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
    }
  }
  -- neorg
  use {
    'nvim-neorg/neorg',
    after = 'nvim-treesitter',
    run = ':Neorg sync-parsers',
    config = function()
      require'neorg'.setup {
        load = {
          ['core.defaults'] = {},
          ['core.norg.concealer'] = {},
          ['core.norg.completion'] = {
            config = {
              engine = 'nvim-cmp',
            },
          },
          ['core.export'] = {},
          ['core.integrations.telescope'] = {},
          ['core.norg.dirman'] = {
            config = {
              workspaces = {
                note = '~/note',
              }
            }
          },
          ['core.gtd.base'] = {
            config = {
              workspace = 'note',
            },
          },
        }
      }
    end,
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-neorg/neorg-telescope',
    }
  }
  -- telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-dap.nvim',
      'cljoly/telescope-repo.nvim',
      'danielpieper/telescope-tmuxinator.nvim',
    },
    config = function ()
      local telescope = require'telescope'
      telescope.setup ()
      telescope.load_extension('dap')
      telescope.load_extension('noice')
      telescope.load_extension('refactoring')
      telescope.load_extension('repo')
      telescope.load_extension('tmuxinator')
    end,
  }
  -- gitsigns
  use {
    'lewis6991/gitsigns.nvim',
    config = function ()
      require'gitsigns'.setup {
        current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 500,
        ignore_whitespace = false,
      }
    }
    end
  }
  -- toggleterm
  use {
    'akinsho/toggleterm.nvim',
    tag = 'v2.*',
    config = function()
      require'toggleterm'.setup ()
    end
  }
  -- octo
  use {
    'pwntester/octo.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons',
      'nvim-telescope/telescope.nvim',
    },
    config = function ()
      require'octo'.setup({
        default_remote = {"upstream", "origin"};
        ssh_aliases = {},
        reaction_viewer_hint_icon = "";
        user_icon = " ";
        timeline_marker = "";
        timeline_indent = "2";
        right_bubble_delimiter = "";
        left_bubble_delimiter = "";
        github_hostname = "";
        snippet_context_lines = 4;
        gh_env = {},
        issues = {
          order_by = {
            field = "CREATED_AT",
            direction = "DESC",
          }
        },
        pull_requests = {
          order_by = {
            field = "CREATED_AT",
            direction = "DESC",
          },
          always_select_remote_on_create = "false",
        },
        file_panel = {
          size = 10,
          use_icons = true,
        },
        mappings = {
          issue = {
            close_issue = { lhs = "<space>ic", desc = "close issue" },
            reopen_issue = { lhs = "<space>io", desc = "reopen issue" },
            list_issues = { lhs = "<space>il", desc = "list open issues on same repo" },
            reload = { lhs = "<C-r>", desc = "reload issue" },
            open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
            copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
            add_assignee = { lhs = "<space>aa", desc = "add assignee" },
            remove_assignee = { lhs = "<space>ad", desc = "remove assignee" },
            create_label = { lhs = "<space>lc", desc = "create label" },
            add_label = { lhs = "<space>la", desc = "add label" },
            remove_label = { lhs = "<space>ld", desc = "remove label" },
            goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },
            add_comment = { lhs = "<space>ac", desc = "add comment" },
            delete_comment = { lhs = "<space>dc", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "go to next comment" },
            prev_comment = { lhs = "[c", desc = "go to previous comment" },
            react_hooray = { lhs = "<space>rp", desc = "add/remove 🎉 reaction" },
            react_heart = { lhs = "<space>rh", desc = "add/remove ❤️ reaction" },
            react_eyes = { lhs = "<space>re", desc = "add/remove 👀 reaction" },
            react_thumbs_up = { lhs = "<space>r+", desc = "add/remove 👍 reaction" },
            react_thumbs_down = { lhs = "<space>r-", desc = "add/remove 👎 reaction" },
            react_rocket = { lhs = "<space>rr", desc = "add/remove 🚀 reaction" },
            react_laugh = { lhs = "<space>rl", desc = "add/remove 😄 reaction" },
            react_confused = { lhs = "<space>rc", desc = "add/remove 😕 reaction" },
          },
          pull_request = {
            checkout_pr = { lhs = "<space>po", desc = "checkout PR" },
            merge_pr = { lhs = "<space>pm", desc = "merge commit PR" },
            squash_and_merge_pr = { lhs = "<space>psm", desc = "squash and merge PR" },
            list_commits = { lhs = "<space>pc", desc = "list PR commits" },
            list_changed_files = { lhs = "<space>pf", desc = "list PR changed files" },
            show_pr_diff = { lhs = "<space>pd", desc = "show PR diff" },
            add_reviewer = { lhs = "<space>va", desc = "add reviewer" },
            remove_reviewer = { lhs = "<space>vd", desc = "remove reviewer request" },
            close_issue = { lhs = "<space>ic", desc = "close PR" },
            reopen_issue = { lhs = "<space>io", desc = "reopen PR" },
            list_issues = { lhs = "<space>il", desc = "list open issues on same repo" },
            reload = { lhs = "<C-r>", desc = "reload PR" },
            open_in_browser = { lhs = "<C-b>", desc = "open PR in browser" },
            copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
            goto_file = { lhs = "gf", desc = "go to file" },
            add_assignee = { lhs = "<space>aa", desc = "add assignee" },
            remove_assignee = { lhs = "<space>ad", desc = "remove assignee" },
            create_label = { lhs = "<space>lc", desc = "create label" },
            add_label = { lhs = "<space>la", desc = "add label" },
            remove_label = { lhs = "<space>ld", desc = "remove label" },
            goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },
            add_comment = { lhs = "<space>ca", desc = "add comment" },
            delete_comment = { lhs = "<space>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "go to next comment" },
            prev_comment = { lhs = "[c", desc = "go to previous comment" },
            react_hooray = { lhs = "<space>rp", desc = "add/remove 🎉 reaction" },
            react_heart = { lhs = "<space>rh", desc = "add/remove ❤️ reaction" },
            react_eyes = { lhs = "<space>re", desc = "add/remove 👀 reaction" },
            react_thumbs_up = { lhs = "<space>r+", desc = "add/remove 👍 reaction" },
            react_thumbs_down = { lhs = "<space>r-", desc = "add/remove 👎 reaction" },
            react_rocket = { lhs = "<space>rr", desc = "add/remove 🚀 reaction" },
            react_laugh = { lhs = "<space>rl", desc = "add/remove 😄 reaction" },
            react_confused = { lhs = "<space>rc", desc = "add/remove 😕 reaction" },
          },
          review_thread = {
            goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },
            add_comment = { lhs = "<space>ca", desc = "add comment" },
            add_suggestion = { lhs = "<space>sa", desc = "add suggestion" },
            delete_comment = { lhs = "<space>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "go to next comment" },
            prev_comment = { lhs = "[c", desc = "go to previous comment" },
            select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
            select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            react_hooray = { lhs = "<space>rp", desc = "add/remove 🎉 reaction" },
            react_heart = { lhs = "<space>rh", desc = "add/remove ❤️ reaction" },
            react_eyes = { lhs = "<space>re", desc = "add/remove 👀 reaction" },
            react_thumbs_up = { lhs = "<space>r+", desc = "add/remove 👍 reaction" },
            react_thumbs_down = { lhs = "<space>r-", desc = "add/remove 👎 reaction" },
            react_rocket = { lhs = "<space>rr", desc = "add/remove 🚀 reaction" },
            react_laugh = { lhs = "<space>rl", desc = "add/remove 😄 reaction" },
            react_confused = { lhs = "<space>rc", desc = "add/remove 😕 reaction" },
          },
          submit_win = {
            approve_review = { lhs = "<C-a>", desc = "approve review" },
            comment_review = { lhs = "<C-m>", desc = "comment review" },
            request_changes = { lhs = "<C-r>", desc = "request changes review" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
          },
          review_diff = {
            add_review_comment = { lhs = "<space>ca", desc = "add a new review comment" },
            add_review_suggestion = { lhs = "<space>sa", desc = "add a new review suggestion" },
            focus_files = { lhs = "<leader>e", desc = "move focus to changed file panel" },
            toggle_files = { lhs = "<leader>b", desc = "hide/show changed files panel" },
            next_thread = { lhs = "]t", desc = "move to next thread" },
            prev_thread = { lhs = "[t", desc = "move to previous thread" },
            select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
            select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            toggle_viewed = { lhs = "<leader><space>", desc = "toggle viewer viewed state" },
          },
          file_panel = {
            next_entry = { lhs = "j", desc = "move to next changed file" },
            prev_entry = { lhs = "k", desc = "move to previous changed file" },
            select_entry = { lhs = "<cr>", desc = "show selected changed file diffs" },
            refresh_files = { lhs = "R", desc = "refresh changed files panel" },
            focus_files = { lhs = "<leader>e", desc = "move focus to changed file panel" },
            toggle_files = { lhs = "<leader>b", desc = "hide/show changed files panel" },
            select_next_entry = { lhs = "]q", desc = "move to previous changed file" },
            select_prev_entry = { lhs = "[q", desc = "move to next changed file" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            toggle_viewed = { lhs = "<leader><space>", desc = "toggle viewer viewed state" },
          }
        }
      })
    end
  }
end)
