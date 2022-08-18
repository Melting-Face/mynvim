-- python path for dap-python
local pythonBinPath = '/bin/python3'
local pythonPath = ''
if vim.fn.executable('/usr/local/Caskroom/miniforge/base' .. pythonBinPath) == 1 then
  pythonPath = '/usr/local/Caskroom/miniforge/base' .. pythonBinPath
elseif vim.fn.executable('/opt/homebrew/Caskroom/miniforge/base' .. pythonBinPath) == 1 then
  pythonPath = '/opt/homebrew/Caskroom/miniforge/base' .. pythonBinPath
elseif vim.fn.executable('/opt/homebrew' .. pythonBinPath) == 1 then
  pythonPath = '/opt/homebrew' .. pythonBinPath
else
  pythonPath = '/usr/local' .. pythonBinPath
end 

-- nvim-dap
local dap = require'dap'
local dapui = require'dapui'
require'dap-python'.setup(pythonPath)

-- adapter
dap.adapters.node2 = {
  type = 'executable',
  command = 'node',
  args = {os.getenv('HOME') .. '/dev/microsoft/vscode-node-debug2/out/src/nodeDebug.js'},
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

dap.listeners.before['event_progressStart']['progress-notifications'] = function(session, body)
  local notif_data = get_notif_data("dap", body.progressId)

  local message = format_message(body.message, body.percentage)
  notif_data.notification = vim.notify(message, "info", {
    title = format_title(body.title, session.config.type),
    icon = spinner_frames[1],
    timeout = false,
    hide_from_history = false,
  })

  notif_data.notification.spinner = 1,
  update_spinner("dap", body.progressId)
end

dap.listeners.before['event_progressUpdate']['progress-notifications'] = function(session, body)
  local notif_data = get_notif_data("dap", body.progressId)
  notif_data.notification = vim.notify(format_message(body.message, body.percentage), "info", {
    replace = notif_data.notification,
    hide_from_history = false,
  })
end

dap.listeners.before['event_progressEnd']['progress-notifications'] = function(session, body)
  local notif_data = client_notifs["dap"][body.progressId]
  notif_data.notification = vim.notify(body.message and format_message(body.message) or "Complete", "info", {
    icon = "",
    replace = notif_data.notification,
    timeout = 3000
  })
  notif_data.spinner = nil
end
