vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
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
  -- rainbow csv
  use 'mechatroner/rainbow_csv'
  -- csv.vim
  use 'chrisbra/csv.vim'
  -- vim-fugitive
  use 'tpope/vim-fugitive'
  -- notify
  use 'rcarriga/nvim-notify'
  -- emmet
  use 'mattn/emmet-vim'
  -- starttime
  use 'dstein64/vim-startuptime'
  -- nvim-treesitter extension
  -- neogen
  use {
    'danymat/neogen',
    config = function()
      require('neogen').setup({
        snippet_engine = 'luasnip',
        languages = {
          go = {
            template = {
              annotation_convention = 'godoc',
            }
          },
          lua = {
            template = {
              annotation_convention = "ldoc",
            },
          },
          java = {
            template = {
              annotation_convention = 'javadoc',
            }
          },
          javascript = {
            template = {
              annotation_convention = "jsdoc",
            },
          },
          python = {
            template = {
              annotation_convention = "google_docstrings",
            },
          },
          rust = {
            template = {
              annotation_convention = "rustdoc",
            },
          },
          sh = {
            template = {
              annotation_convention = "google_bash",
            },
          },
          typescript = {
            template = {
              annotation_convention = "tsdoc",
            },
          },
          typescriptreact = {
            template = {
              annotation_convention = "tsdoc",
            },
          },
        },
      })
    end,
    requires = {
      'nvim-treesitter/nvim-treesitter',
    },
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
  -- outline
  use {
    'simrat39/symbols-outline.nvim',
    config = function ()
      require('symbols-outline').setup()
    end
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
  -- firenvim
  use {
    'glacambre/firenvim',
    run = function() vim.fn['firenvim#install'](0) end
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
          null_ls.builtins.formatting.remark,
          null_ls.builtins.formatting.rustfmt,
          null_ls.builtins.formatting.shellharden,
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.yamlfmt,
        },
      })
    end,
    requires = { 'nvim-lua/plenary.nvim' },
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
    tag = 'v2.*',
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
      telescope.load_extension('noice')
      telescope.load_extension('dap')
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
end)
