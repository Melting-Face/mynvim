return {
  -- nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    -- configs/compilers API는 master 브랜치에만 있다 (main은 재작성됨)
    branch = "master",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
    -- 모든 파일에서 하이라이트와 텍스트 오브젝트가 동작하도록 파일을 열 때 로드한다
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      -- Windows에서는 MSVC 대신 zig/gcc/clang으로 파서를 컴파일한다
      if require("configs.paths").is_windows() then
        require("nvim-treesitter.install").compilers = { "zig", "gcc", "clang" }
      end
      require("nvim-treesitter.configs").setup({
        -- 설치 스크립트·CI(headless)에서는 파서를 동기로 설치하고, 일반 실행에서는 UI를 멈추지 않게 비동기로 설치한다
        sync_install = #vim.api.nvim_list_uis() == 0,
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
        ensure_installed = {
          "bash",
          "dockerfile",
          "java",
          "javascript",
          "json",
          "lua",
          "make",
          "markdown",
          "markdown_inline",
          "prisma",
          "python",
          "sql",
          "regex",
          "toml",
          "typescript",
          "yaml",
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            },
            selection_modes = {
              ["@parameter.outer"] = "v",
              ["@function.outer"] = "V",
              ["@class.outer"] = "<c-v>",
            },
            include_surrounding_whitespace = true,
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = { query = "@class.outer", desc = "Next class start" },
              ["]o"] = "@loop.*",
              ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
            -- ]d/[d는 nvim 기본 진단 이동이므로 조건문 이동은 ]i/[i(if)를 쓴다
            goto_next = {
              ["]i"] = "@conditional.outer",
            },
            goto_previous = {
              ["[i"] = "@conditional.outer",
            },
          },
          swap = {
            enable = true,
            -- <leader>a는 Claude Code 키 그룹이므로 swap은 <leader>s(n/p)를 쓴다
            swap_next = {
              ["<leader>sn"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>sp"] = "@parameter.inner",
            },
          },
        },
      })
    end,
  },
}
