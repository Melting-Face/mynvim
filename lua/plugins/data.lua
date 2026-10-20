return {
  -- INFO: CSV
  {
    "mechatroner/rainbow_csv",
    ft = "csv",
  },
  {
    "chrisbra/csv.vim",
    ft = "csv",
  },
  -- NOTE: vim dadbod
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
    },
    keys = {
      { "<localleader>d", "<cmd>DBUIToggle<CR>",        desc = "db ui" },
      { "<leader>da",     "<cmd>DBUIAddConnection<CR>", desc = "add connection" },
    },
  },
}
