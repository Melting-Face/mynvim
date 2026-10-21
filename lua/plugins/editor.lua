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
      { "<leader>ff", ":Telescope find_files<CR>", desc = "find files" },
      { "<leader>fgc", ":Telescope git_bcommits<CR>", desc = "git commit log (buffer)" },
      { "<leader>fgt", ":Telescope git_commits<CR>", desc = "git commit log (project)" },
      { "<leader>fk", ":Telescope keymaps<cr>", desc = "keymaps" },
      { "<leader>fq", ":Telescope quickfix<cr>", desc = "quickfix" },
      { "<leader>fr", ":Telescope registers<cr>", desc = "registers" },
      { "<leader>fs", ":Telescope live_grep<CR>", desc = "search" },
    },
  },
  -- text case
  {
    "johmsalas/text-case.nvim",
    config = function()
      require("textcase").setup({})
    end,
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
      { "<localleader>n", "<cmd>NvimTreeToggle<CR>", desc = "nvim tree" },
      { "<leader>nf", "<cmd>NvimTreeFindFile<CR>", desc = "find files(nvim-tree)" },
    },
  },
}
