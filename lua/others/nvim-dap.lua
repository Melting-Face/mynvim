-- nvim-dap
local dapui = require'dapui'
-- dap-python
local has_dap_python, dap_python = pcall(require, 'dap-python')

local node_path = MASON .. '/node-debug2-adapter/out/src/nodeDebug.js'

local js_adapter_path = MASON .. '/js-debug-adapter';

if has_dap_python == true then
  ASYNC.run(function ()
    local python_path = io.popen('which python3'):read('l')
    dap_python.setup(python_path)
  end)
end

if HAS_DAP == true then
  local has_dap_js, dap_js = pcall(require, 'dap-vscode-js')
  if has_dap_js == true then
    dap_js.setup({
      debugger_path = js_adapter_path,
      adapters = {
        'pwa-node',
        'pwa-chrome',
        'pwa-msedge',
        'node-terminal',
        'pwa-extensionHost',
      },
    })

    for _, language in ipairs { "typescript", "javascript" } do
      DAP.configurations[language] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
    end
  end

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
