print("start")

local mason_root_dir = io.popen('find ~ -name "mason" -type d | grep "nvim/mason"'):read('l')
local isMasonDir = false
if mason_root_dir ~= nil then
  isMasonDir = true
end



print("end")
