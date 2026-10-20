return {
  -- INFO: GIT
  -- vim-fugitive
  "tpope/vim-fugitive",
  -- neogit
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      integrations = {
        diffview = true,
      },
      signs = {
        section = { "*", "=" },
        item = { "*", "=" },
        hunk = { "", "" },
      },
    },
    keys = {
      { "<leader>ng", "<cmd>Neogit<CR>", desc = "neogit" },
    },
  },
  -- gitsigns
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        ignore_whitespace = false,
      },
    },
    event = "BufRead",
    keys = {
      { "<leader>hb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "curret line blame" },
      { "<leader>hd", "<cmd>Gitsigns toggle_deleted<cr>",            desc = "deleted" },
      { "<leader>ht", "<cmd>Gitsigns diffthis<cr>",                  desc = "diff this" },
      { "[h",         "<cmd>Gitsigns prev_hunk<cr>",                 desc = "prev hunk" },
      { "]h",         "<cmd>Gitsigns next_hunk<cr>",                 desc = "next hunk" },
    },
  },
  -- git congflict
  {
    "akinsho/git-conflict.nvim",
    config = true,
    tag = "v2.1.0",
  },
}
