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

      -- mason codelldb 패키지의 실행 파일은 extension/adapter 아래에 있다 (Windows는 .exe)
      dap.adapters.codelldb = {
        type = "executable",
        command = paths.exe(paths.mason_package("codelldb") .. "/extension/adapter/codelldb"),
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
  -- 디버그 어댑터 설치 (설치만 맡기고 어댑터 설정은 아래에서 직접 한다)
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      -- headless(설치 스크립트, CI)에서는 설치를 시작하지 않는다: +qa로 끝나며 설치가 끊기면
      -- mason이 반쪽 디렉터리를 설치됨으로 판단해 다시 설치하지 않는다. 첫 일반 실행 때 설치된다
      ensure_installed = #vim.api.nvim_list_uis() == 0 and {} or require("configs.dap_adapters").list(),
      automatic_installation = false,
    },
  },
  -- nvim-dap-python
  {
    "mfussenegger/nvim-dap-python",
    dependencies = "mfussenegger/nvim-dap",
    ft = "python",
    config = function()
      local paths = require("configs.paths")
      local dap_python = require("dap-python")
      -- 어댑터는 mason이 설치한 debugpy 전용 venv의 python으로 실행한다
      -- mason은 디렉터리만 있으면 설치됨으로 보므로, 설치 완료는 영수증(mason-receipt.json)으로 판단한다
      local debugpy = paths.mason_package("debugpy")
      local adapter_python = paths.is_windows() and (debugpy .. "/venv/Scripts/python.exe")
        or (debugpy .. "/venv/bin/python")
      if not (vim.uv.fs_stat(debugpy .. "/mason-receipt.json") and vim.uv.fs_stat(adapter_python)) then
        vim.notify_once(
          "debugpy가 설치되지 않았거나 설치가 끝나지 않아 Python 디버깅을 쓸 수 없습니다"
            .. " (설치 중이면 잠시 후 nvim을 다시 열고, 계속되면 :MasonInstall --force debugpy)",
          vim.log.levels.WARN
        )
        return
      end
      dap_python.setup(adapter_python)
      -- 디버그 대상 프로그램은 프로젝트 venv(.venv, venv)의 python, 없으면 시스템 python으로 실행한다
      -- (resolve_python을 지정하면 dap-python의 venv 자동 탐지를 건너뛰므로 여기서 직접 찾는다)
      dap_python.resolve_python = function()
        for _, name in ipairs({ ".venv", "venv" }) do
          local dir = vim.fn.getcwd() .. "/" .. name
          local exe = paths.is_windows() and (dir .. "/Scripts/python.exe") or (dir .. "/bin/python")
          if vim.uv.fs_stat(exe) then
            return exe
          end
        end
        local py = paths.python()
        return py ~= "" and py or nil
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
