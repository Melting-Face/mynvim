local filetypes = {
  "c",
  "cpp",
  "rust",
  "lua",
  "python",
  "java",
  "javascript",
  "typescript",
}

return {
  -- INFO: DAP
  -- nvim-dap-ui
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    ft = filetypes,
    config = function()
      local dap = require("dap")

      local paths = require("configs.paths")

      dap.adapters.codelldb = {
        type = "executable",
        command = paths.exe(paths.mason_package("codelldb") .. "/codelldb"),
      }

      dap.configurations.rust = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.c = dap.configurations.rust
      dap.configurations.cpp = dap.configurations.rust
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
    keys = {
      {
        "<leader>b",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "toggle breakpoint",
      },
      {
        "<leader>B",
        function()
          require("dap").set_breakpoint()
        end,
        desc = "set breakpoint",
      },
      {
        "<Leader>lp",
        function()
          require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end,
        desc = "set breakpoint with message",
      },
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "dap run(continue)",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "dap step over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "dap step into",
      },
      {
        "<F12>",
        function()
          require("dap").step_out()
        end,
        desc = "dap step out",
      },
      {
        "<Leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "open repl",
      },
      {
        "<Leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "run last",
      },
      {
        "<Leader>dh",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "dap ui widgets",
        mode = { "n", "v" },
      },
      {
        "<Leader>dp",
        function()
          require("dap.ui.widgets").preview()
        end,
        desc = "dap ui preview",
        mode = { "n", "v" },
      },
      {
        "<Leader>df",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.frames)
        end,
        desc = "dap ui widgets float center(frame)",
      },
      {
        "<Leader>ds",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.scopes)
        end,
        desc = "dap ui widgets float center(scope)",
      },
      {
        "<Leader>dt",
        function()
          require("dapui").toggle()
        end,
        desc = "dap ui toggle",
      },
    },
  },
  -- dap-virtual-text
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = "mfussenegger/nvim-dap",
    config = true,
    ft = filetypes,
  },
  -- nvim-dap-python
  {
    "mfussenegger/nvim-dap-python",
    dependencies = "mfussenegger/nvim-dap",
    ft = "python",
    config = function()
      local py = require("configs.paths").python()
      if py ~= "" then
        -- debugpy가 설치되어 있을 때만 설정
        if vim.system({ py, "-c", "import debugpy" }):wait().code == 0 then
          require("dap-python").setup(py)
        end
      end
    end,
    keys = {
      {
        "<leader>dc",
        function()
          require("dap-python").test_class()
        end,
        desc = "python test class",
        ft = "python",
      },
      {
        "<leader>dd",
        '<ESC>:lua require("dap-python").debug_selection()<CR>',
        desc = "python debug select",
        ft = "python",
      },
      {
        "<leader>dm",
        function()
          require("dap-python").test_method()
        end,
        desc = "python test method",
        ft = "python",
      },
    },
  },
}
