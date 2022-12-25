local tt = require("toggleterm.terminal").Terminal

local lazygit = tt:new({
	cmd = "lazygit",
	direction = "float",
	float_opts = {
		border = "single",
	},
})

local lazydocker = tt:new({
	cmd = "lazydocker",
	direction = "float",
	float_opts = {
		border = "single",
	},
})

local lazynpm = tt:new({
	cmd = "lazynpm",
	direction = "float",
	float_opts = {
		border = "single",
	},
})

function _lazygit()
	lazygit:toggle()
end

function _lazydocker()
	lazydocker:toggle()
end

function _lazynpm()
  lazynpm:toggle()
end
