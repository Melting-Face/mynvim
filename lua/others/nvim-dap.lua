-- nvim-dap
local dapui = require'dapui'
-- llvm-path
local llvm_path = io.popen('echo $(brew --prefix llvm)/bin'):read("l")
-- lldb-path
local lldb_path = llvm_path .. '/lldb-vscode'
-- node-path
local node_path = MASON .. '/node-debug2-adapter/out/src/nodeDebug.js'
-- dap-python
local has_dap_python, dap_python = pcall(require, 'dap-python')

if has_dap_python == true then
  local python_path = io.popen('which python3'):read('l')
  dap_python.setup(python_path)
end

if HAS_DAP == true then
  DAP.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = {
      node_path,
    },
  }

  DAP.adapters.nlua = function(callback, config)
    if config.port ~= nil then
      callback({
        type = 'server',
        host = config.host,
        port = config.port
      })
    else
      require'osv'.run_this()
    end
  end

  DAP.adapters.lldb = {
    type = 'executable',
    command = lldb_path,
    name = 'lldb'
  }

  -- config
  DAP.configurations.javascript = {
    {
      name = 'Launch',
      type = 'node2',
      request = 'launch',
      program = '${file}',
      cwd = '${workspaceFolder}',
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
    },
    {
      -- For this to work you need to make sure the node process is started with the `--inspect` flag.
      name = 'Attach to process',
      type = 'node2',
      request = 'attach',
      processId = require'dap.utils'.pick_process,
    },
  }

  DAP.configurations.lua = {
    {
      type = 'nlua',
      request = 'attach',
      name = "Attach to running Neovim instance",
      host = function()
        local value = vim.fn.input('Host [127.0.0.1]: ')
        if value ~= "" then
          return value
        end
        return '127.0.0.1'
      end,
      port = function()
        local val = tonumber(vim.fn.input('Port: '))
        return val
      end,
    }
  }

  DAP.configurations.cpp = {
    {
      name = 'Launch',
      type = 'lldb',
      request = 'launch',
      program = '${file}',
      cwd = '${workspaceFolder}',
      stopOnEntry = true,
      args = {},
      runInTerminal = true,
    },
  }

  -- If you want to use this for Rust and C, add something like this:

  DAP.configurations.c = DAP.configurations.cpp
  DAP.configurations.rust = DAP.configurations.cpp

  DAP.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  DAP.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  DAP.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end
