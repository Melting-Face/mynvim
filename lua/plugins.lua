return {
	-- devicons
	'kyazdani42/nvim-web-devicons',
	-- multi cursor
	'mg979/vim-visual-multi',
	-- theme tokyonight
	'folke/tokyonight.nvim',
	-- async
	'nvim-lua/plenary.nvim',
	-- vim-fugitive
	'tpope/vim-fugitive',
	-- notify
	'rcarriga/nvim-notify',
	-- emmet
	'mattn/emmet-vim',
	-- rainbow csv
	'mechatroner/rainbow_csv',
	-- starttime
	'dstein64/vim-startuptime',
	-- cache
	'lewis6991/impatient.nvim',
	-- tabular
	'godlygeek/tabular',
	-- whitespace
	'ntpeters/vim-better-whitespace',
	-- minimap
	'wfxr/minimap.vim',
	-- neogit
	{
		'TimUntersberger/neogit',
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
    config={},
	},
	-- nvim-treesitter
	{
		'nvim-treesitter/nvim-treesitter',
		dependencies = {
			'nvim-treesitter/nvim-treesitter-textobjects',
			'windwp/nvim-ts-autotag',
		},
		build = ':TSUpdate',
		config = function()
			require('nvim-treesitter.install').compilers = { 'gcc-12' }
			require('nvim-treesitter.configs').setup({
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
					'tsx',
					'typescript',
					'vim',
					'yaml',
				},
				autotag = {
					enable = true,
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							['af'] = '@function.outer',
							['if'] = '@function.inner',
							['ac'] = '@class.outer',
							['ic'] = '@class.inner',
						},
						selection_modes = {
							['@parameter.outer'] = 'v',
							['@function.outer'] = 'V',
							['@class.outer'] = '<c-v>',
						},
						include_surrounding_whitespace = true,
					},
					lsp_interop = {
						enable = true,
						border = 'none',
						floating_preview_opts = {},
						peek_definition_code = {
							['<leader>df'] = '@function.outer',
							['<leader>dF'] = '@class.outer',
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							[']m'] = '@function.outer',
							[']]'] = '@class.outer',
						},
						goto_next_end = {
							[']M'] = '@function.outer',
							[']['] = '@class.outer',
						},
						goto_previous_start = {
							['[m'] = '@function.outer',
							['[['] = '@class.outer',
						},
						goto_previous_end = {
							['[M'] = '@function.outer',
							['[]'] = '@class.outer',
						},
					},
					swap = {
						enable = true,
						swap_next = {
							['<leader>a'] = '@parameter.inner',
						},
						swap_previous = {
							['<leader>A'] = '@parameter.inner',
						},
					},
				},
			})
		end,
	},
	-- package-info
	{
		'vuki656/package-info.nvim',
		dependencies = {
			'MunifTanjim/nui.nvim',
		},
		config = true,
	},
	-- neotest
	{
		'nvim-neotest/neotest',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-treesitter/nvim-treesitter',
			'antoinemadec/FixCursorHold.nvim',
			'nvim-neotest/neotest-plenary',
			'nvim-neotest/neotest-python',
			'haydenmeade/neotest-jest',
		},
		config = function()
			require('neotest').setup({
				adapters = {
					require('neotest-python'),
					require('neotest-plenary'),
					require('neotest-jest'),
				},
			})
		end,
	},
	-- outline
	{
		'simrat39/symbols-outline.nvim',
		config = true,
	},
	-- java/typescript
	{
		'mxsdev/nvim-dap-vscode-js',
		dependencies = {
			'mfussenegger/nvim-dap',
		},
	},
	-- neodev
	{
		'folke/neodev.nvim',
		config = function()
			require('neodev').setup({
				library = {
					plugins = {
						'neotest',
					},
					types = true,
				},
			})
		end,
	},
	-- luapad
	{
		'rafcamlet/nvim-luapad',
		config = true,
	},
	-- neogen
	{
		'danymat/neogen',
		dependencies = {
			'nvim-treesitter/nvim-treesitter',
		},
		config = function()
			local lang_doc_map = {
				go = 'godoc',
				lua = 'ldoc',
				java = 'javadoc',
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
	},
	-- for winbar
	{
		'SmiteshP/nvim-navic',
		dependencies = 'neovim/nvim-lspconfig',
		config = function()
			require('nvim-navic').setup({
				highlight = true,
			})
		end,
	},
	-- magma
	{
		'dccsillag/magma-nvim',
		build = ':UpdateRemotePlugins',
	},
	-- vim dadbod
	{
		'kristijanhusak/vim-dadbod-ui',
		dependencies = {
			'tpope/vim-dadbod',
		},
	},
	-- crates
	{
		'saecki/crates.nvim',
		event = {
			'BufRead Cargo.toml',
		},
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
		config = true,
	},
	-- noice
	{
		'folke/noice.nvim',
		dependencies = {
			'MunifTanjim/nui.nvim',
			'rcarriga/nvim-notify',
		},
		config = {},
	},
	-- restnvim
	{
		'rest-nvim/rest.nvim',
		ft = 'http',
		dependencies = {
			'nvim-lua/plenary.nvim',
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
							return vim.fn.system({ 'tidy', '-i', '-q', '-' }, body)
						end,
					},
				},
				-- Jump to request line on run
				jump_to_request = false,
				env_file = '.env',
				custom_dynamic_variables = {},
				yank_dry_run = true,
			})
		end,
	},
	-- null_ls
	{
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
					null_ls.builtins.formatting.jq,
					null_ls.builtins.formatting.remark,
					null_ls.builtins.formatting.rustfmt,
					null_ls.builtins.formatting.shellharden,
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.yamlfmt,
				},
			})
		end,
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
	},
	-- todo comment
	{
		'folke/todo-comments.nvim',
		dependencies = 'nvim-lua/plenary.nvim',
		config = true,
	},
	-- trouble
	{
		'folke/trouble.nvim',
		dependencies = 'kyazdani42/nvim-web-devicons',
		config = function()
			require('trouble').setup({
				mode = 'document_diagnostics',
			})
		end,
	},
	-- autopairs
	{
		'windwp/nvim-autopairs',
		config = function()
			require('nvim-autopairs').setup({
				disable_filetype = {
					'TelescopePrompt',
					'vim',
				},
			})
		end,
	},
	-- markdown
	{
		'iamcco/markdown-preview.nvim',
		build = 'cd app && npm install',
		setup = function()
			vim.g.mkdp_filetypes = {
				'markdown',
			}
		end,
		ft = {
			'markdown',
		},
	},
	-- whici keys
	{
		'folke/which-key.nvim',
		config = function()
			require('which-key').setup()
		end,
	},
	-- indent-blankline
	{
		'lukas-reineke/indent-blankline.nvim',
		config = function()
			require('indent_blankline').setup({
				show_current_context = true,
				show_current_context_start = true,
				show_end_of_line = true,
			})
		end,
	},
	-- bufferline
	{
		'akinsho/bufferline.nvim',
		dependencies = 'kyazdani42/nvim-web-devicons',
		config = function()
			require('bufferline').setup({
				options = {
					separator_style = 'padded_slant',
					numbers = function(opts)
						return string.format('%s·%s', opts.raise(opts.id), opts.lower(opts.ordinal))
					end,
					diagnostics = 'nvim_lsp',
				},
			})
		end,
	},
	-- scope.nvim for tab
	{
		'tiagovla/scope.nvim',
		config = true,
	},
	-- nvim-jdtls
	{
		'mfussenegger/nvim-jdtls',
		ft = {
			'java',
		},
	},
	-- nvim-dap-go
	{
		'leoluz/nvim-dap-go',
		dependencies = {
			'mfussenegger/nvim-dap',
		},
		config = true,
	},
	-- nvim-dap-python
	{
		'mfussenegger/nvim-dap-python',
		dependencies = {
			'mfussenegger/nvim-dap',
		},
	},
	-- rust-tools
	{
		'simrat39/rust-tools.nvim',
		dependencies = {
			'neovim/nvim-lspconfig',
			'nvim-lua/plenary.nvim',
			'mfussenegger/nvim-dap',
		},
		config = function()
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
			require('rust-tools').setup(opt)
		end,
	},
	-- nvim-dap-lua
	{
		'jbyuki/one-small-step-for-vimkind',
		dependencies = {
			'mfussenegger/nvim-dap',
		},
	},
	-- nvim-dap-ui
	{
		'rcarriga/nvim-dap-ui',
		dependencies = {
			'mfussenegger/nvim-dap',
		},
		config = true,
	},
	{
		'theHamsta/nvim-dap-virtual-text',
		dependencies = {
			'mfussenegger/nvim-dap',
		},
		config = true,
	},
	-- mason
	{
		'williamboman/mason.nvim',
		dependencies = {
			'williamboman/mason-lspconfig.nvim',
		},
		config = true,
	},
  -- mason lsp
	{
		'williamboman/mason-lspconfig.nvim',
		dependencies = { 'neovim/nvim-lspconfig' },
		config = {
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
    }
	},
  -- mason null-ls
  {
    'jayp0521/mason-null-ls.nvim',
		dependencies = {
		  'williamboman/mason.nvim',
      'jose-elias-alvarez/null-ls.nvim'
    },
    config = {
      ensure_installed = {
        'black',
        'eslint_d',
        'flake8',
        'golangci_lint',
        'hadolint',
        'isort',
        'jq',
        'luacheck',
        'remark',
        'rustfmt',
        'shellcheck',
        'shellharden',
        'stylua',
        'yamlfmt',
        'yamllint',
      },
      automatic_installation = true,
    },
  },
	-- alpha
	{
		'goolord/alpha-nvim',
		dependencies = {
			'kyazdani42/nvim-web-devicons',
		},
		config = function()
			require('alpha').setup(require('alpha.themes.dashboard').config)
		end,
	},
	-- comment
	{
		'numToStr/Comment.nvim',
		config = true,
	},
	-- surround
	{
		'kylechui/nvim-surround',
		config = true,
	},
	-- nvim tree
	{
		'kyazdani42/nvim-tree.lua',
		dependencies = {
			'kyazdani42/nvim-web-devicons',
		},
		config = true,
	},
	-- project nvim
	{
		'ahmedkhalf/project.nvim',
		config = function()
			require('project_nvim').setup()
		end,
	},
	-- lualine
	{
		'nvim-lualine/lualine.nvim',
		dependencies = {
			'kyazdani42/nvim-web-devicons',
			opt = true,
		},
		after = 'nvim-navic',
		config = function()
			local function navic_winbar()
				local navic = require('nvim-navic')
				if navic.is_available() then
					return '%#WinBarSeparator#' .. navic.get_location() .. '%#WinBarSeparator#'
				else
					return '%#WinBarSeparator#' .. '%#WinBarSeparator#'
				end
			end
			require('lualine').setup({
				options = {
					theme = 'tokyonight',
					disabled_filetypes = {
						winbar = {
							'alpha',
							'dbui',
							'dbout',
							'notify',
							'NvimTree',
							'packer',
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
					'fugitive',
					'nvim-dap-ui',
					'nvim-tree',
					'toggleterm',
				},
			})
		end,
	},
	-- refactoring
	{
		'ThePrimeagen/refactoring.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-treesitter/nvim-treesitter',
		},
		config = true,
	},
	-- cmp
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'L3MON4D3/LuaSnip',
			'saadparwaiz1/cmp_luasnip',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
		},
	},
	-- neorg
	{
		'nvim-neorg/neorg',
		after = 'nvim-treesitter',
		build = ':Neorg sync-parsers',
		config = function()
			require('neorg').setup({
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
				},
			})
		end,
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-neorg/neorg-telescope',
		},
	},
	-- telescope
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-dap.nvim',
			'cljoly/telescope-repo.nvim',
			'danielpieper/telescope-tmuxinator.nvim',
		},
		config = function()
			local telescope = require('telescope')
			telescope.setup()
			telescope.load_extension('dap')
			telescope.load_extension('noice')
			telescope.load_extension('projects')
			telescope.load_extension('refactoring')
			telescope.load_extension('repo')
			telescope.load_extension('tmuxinator')
		end,
	},
	-- gitsigns
	{
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup({
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = 'eol',
					delay = 500,
					ignore_whitespace = false,
				},
			})
		end,
	},
	-- toggleterm
	{
		'akinsho/toggleterm.nvim',
		version = '*',
		config = true,
	},
}
