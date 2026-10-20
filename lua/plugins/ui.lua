return {
  -- theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end,
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
}
