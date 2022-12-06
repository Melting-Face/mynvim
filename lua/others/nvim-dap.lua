-- nvim-dap
local dapui = require'dapui'
-- node-path
local node_path = MASON .. '/node-debug2-adapter/out/src/nodeDebug.js'
-- dap-python
local has_dap_python, dap_python = pcall(require, 'dap-python')

if has_dap_python == true then
  ASYNC.run(function ()
    local python_path = io.popen('which python3'):read('l')
    dap_python.setup(python_path)
  end)
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
    callback({
      type = 'server',
      host = config.host or "127.0.0.1",
      port = config.port or 8086
    })
  end

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
    }
  }


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
