-- nvim-dap
local dapui = require'dapui'
-- node-debug
local node_debug = '/packages/node-debug2-adapter/out/src/nodeDebug.js'
local node_path = MASON .. node_debug
-- dap-python
local has_dap_python = pcall(require, 'dap-python')
if has_dap_python == true then
  local python_path = io.popen('which python3'):read('l')
  require'dap-python'.setup(python_path)
end

if io.open(node_path) ~= nil then
  dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = {
      node_path,
    },
  }
  -- config
  dap.configurations.javascript = {
    {
      name = 'Launch',
      type = 'node2',
      request = 'launch',
      program = '${file}',
      cwd = vim.fn.getcwd(),
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
end

dap.configurations.lua = {
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

dap.adapters.nlua = function(callback, config)
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

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
