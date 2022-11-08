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
  -- minimap
  use 'wfxr/minimap.vim'
  -- tagbar
  use 'preservim/tagbar'
  -- async
  use 'nvim-lua/plenary.nvim'
  -- notify
  use 'rcarriga/nvim-notify'
  -- rainbow csv
  use 'mechatroner/rainbow_csv'
  -- csv.vim
  use 'chrisbra/csv.vim'
  -- vim-fugitive
  use 'tpope/vim-fugitive'
  -- vim dadbod
  use {
    'kristijanhusak/vim-dadbod-ui',
    requires = { 'tpope/vim-dadbod' }
  }
  use {
    'pwntester/octo.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    config = function ()
      require"octo".setup()
    end
  }
  -- restnvim
  use {
    'rest-nvim/rest.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
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
              return vim.fn.system({"tidy", "-i", "-q", "-"}, body)
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
        require("null-ls").setup({
          sources = {
            require("null-ls").builtins.diagnostics.eslint_d,
            require("null-ls").builtins.diagnostics.flake8,
          },
        })
    end,
    requires = { 'nvim-lua/plenary.nvim' },
  })
  -- trouble
  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require'trouble'.setup ()
    end
  }
  -- autopairs
  use {
	  'windwp/nvim-autopairs',
    config = function()
      require("nvim-autopairs").setup ({
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
    run = "cd app && npm install",
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
      require("which-key").setup ()
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
    tag = "v2.*",
    requires = 'kyazdani42/nvim-web-devicons',
    config = function ()
      require("bufferline").setup {
        options = {
          separator_style = 'padded_slant',
          numbers = function(opts)
            return string.format('%s·%s', opts.raise(opts.id), opts.lower(opts.ordinal))
          end,
          diagnostics = "nvim_lsp",
        },
      }
    end
  }
  -- scope.nvim for tab
  use {
    'tiagovla/scope.nvim',
    config = function ()
      require("scope").setup ()
    end
  }
  -- nvim-jdtls
  use {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' }
  }
  -- nvim-dap-go
  if io.popen('which dlv'):read('l') ~= nil then
    use {
      'leoluz/nvim-dap-go',
      requires = {
        'mfussenegger/nvim-dap'
      },
      config = function ()
        require('dap-go').setup ()
      end,
    }
  end
  -- nvim-dap-python
  if io.popen('pip list | grep -n debugpy'):read('l') ~= nil then
    use {
      'mfussenegger/nvim-dap-python',
      requires = {
        'mfussenegger/nvim-dap'
      },
    }
  end
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
            type = "executable",
            command = "lldb-vscode",
            name = "rt_lldb",
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
      require('nvim-dap-virtual-text').setup ()
    end
  }
  -- lsp installer
  use {
    "williamboman/mason-lspconfig.nvim",
    requires = { 'neovim/nvim-lspconfig' },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          'bashls',
          'dockerls',
          'gopls',
          'jdtls',
          'jedi_language_server',
          'jsonls',
          'rust_analyzer',
          'sumneko_lua',
          'sqlls',
          'sqls',
          'tsserver',
          'vimls',
          'yamlls',
        },
        automatic_installation = true,
      })
    end
  }
  use {
    "williamboman/mason.nvim",
    requires = { 'williamboman/mason-lspconfig.nvim' },
    config = function()
      require("mason").setup()
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
      "kylechui/nvim-surround",
      tag = "*",
      config = function()
          require("nvim-surround").setup ()
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
  -- lualine
  use {
    'nvim-lualine/lualine.nvim',
    requires = {
      'kyazdani42/nvim-web-devicons',
      opt = true
    },
    config = function()
      require'lualine'.setup {
        options = { theme = 'palenight' }
      }
    end
  }
  -- nvim-treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function ()
      require'nvim-treesitter.configs'.setup {
        sync_install = true,
        ensure_installed = {
          'bash',
          'dockerfile',
          'go',
          'http',
          'java',
          'javascript',
          'json',
          'lua',
          'markdown',
          'python',
          'regex',
          'rust',
          'sql',
          'tsx',
          'typescript',
          'vim',
          'yaml',
        },
      }
    end
  }
  -- telescope
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    requires = { 'nvim-lua/plenary.nvim' },
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
  -- toggleterm
  use {
    "akinsho/toggleterm.nvim",
    tag = 'v2.*',
    config = function()
      require("toggleterm").setup ()
    end
  }
end)
