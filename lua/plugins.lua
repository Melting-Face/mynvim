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
          'clangd',
          'cmake',
          'dockerls',
          'eslint',
          'golangci_lint_ls',
          'gopls',
          'jedi_language_server',
          'jsonls',
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
    "williamboman/mason.nvim",
    requires = { 'williamboman/mason-lspconfig.nvim' },
    config = function()
      require("mason").setup()
    end
  }
  -- nvim-lint
  use {
    'mfussenegger/nvim-lint',
    config = function ()
      require('lint').linters_by_ft = {
        javascript = { 'eslint' },
        markdown = {'vale' },
        python = { 'flake8' },
        typescript = { 'eslint' },
      }
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
    run = ':TSUpdate'
  }
  -- telescope
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    requires = { 'nvim-lua/plenary.nvim' }
  }
  -- gitsigns
  use 'lewis6991/gitsigns.nvim'
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
