local servers = require("configs.lsp_servers")
local language_servers = servers.list()

return {
  -- mason
  {
    "mason-org/mason.nvim",
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
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    opts = {
      automatic_installation = true,
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
        desc = "java test class",
        ft = "java",
      },
      {
        "<leader>dm",
        function()
          require("jdtls").test_nearest_method()
        end,
        desc = "java test nearest method",
        ft = "java",
      },
    },
  },
  -- mason lsp
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
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
      -- 한 버퍼에 그런 서버가 둘 이상이면 처음 붙은 서버만 쓴다 (두 번째 attach는 navic이 경고를 띄움)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserNavic", {}),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider and vim.b[ev.buf].navic_client_id == nil then
            require("nvim-navic").attach(client, ev.buf)
          end
        end,
      })
      require("mason-lspconfig").setup(opts)
    end,
  },
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
}
