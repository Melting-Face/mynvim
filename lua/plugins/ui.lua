return {
  -- theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      -- mocha 팔레트를 Claude 다크 UI 톤(따뜻한 회갈색 배경, 크림 글자, 주황 강조)으로 덮어쓴다
      -- 오래 봐도 눈이 덜 피곤하도록 채도를 낮췄고, 글자색은 배경 대비 4.5:1(WCAG AA) 이상을 유지한다
      -- 원래 색은 :colorscheme catppuccin-frappe 등 다른 flavour로 바로 돌아갈 수 있다
      require("catppuccin").setup({
        flavour = "mocha",
        -- 창을 나눴을 때 비활성 창 배경을 어둡게 해 지금 커서가 있는 창이 드러나게 한다
        dim_inactive = {
          enabled = true,
          shade = "dark",
          percentage = 0.15,
        },
        -- 기본 창 경계선(crust)은 배경과 거의 같아 보이지 않으므로 대비 3:1 이상인 색으로 그린다
        custom_highlights = function(colors)
          return {
            WinSeparator = { fg = colors.overlay1 },
          }
        end,
        color_overrides = {
          mocha = {
            rosewater = "#E0D3C6",
            flamingo = "#D6B8A6",
            pink = "#C9A3B3",
            mauve = "#C98A6E", -- 키워드: 채도를 낮춘 Claude 주황
            red = "#D27A66", -- Crail(#C15F3C)은 배경 대비가 낮아 밝게 조정
            maroon = "#CFA18A",
            peach = "#D2A577",
            yellow = "#CDB98C",
            green = "#9EAD86",
            teal = "#8FAAA0",
            sky = "#9AAFBC",
            sapphire = "#8BA2B5",
            blue = "#8E9FB8",
            lavender = "#A9A2C4",
            text = "#DEDBD0",
            subtext1 = "#C2C0B6",
            subtext0 = "#B1ADA1",
            overlay2 = "#9A968B",
            overlay1 = "#85817A",
            overlay0 = "#6F6C66",
            surface2 = "#57554F",
            surface1 = "#45433F",
            surface0 = "#34332F",
            base = "#262624",
            mantle = "#1F1E1D",
            crust = "#181817",
          },
        },
      })
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
