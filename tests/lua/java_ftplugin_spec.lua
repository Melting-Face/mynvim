vim.opt.rtp:prepend(vim.fn.getcwd())
-- ftplugin/java.lua: jdtls가 없으면 start_or_attach를 부르지 않고 WARN 안내만 한다
local started = 0
package.loaded["jdtls"] = {
  start_or_attach = function()
    started = started + 1
  end,
}
local notes = {}
vim.notify_once = function(msg, level)
  table.insert(notes, { msg = msg, level = level })
  return true
end

vim.fn.executable = function()
  return 0
end
dofile("ftplugin/java.lua")
assert(started == 0, "jdtls가 없는데 start_or_attach가 호출됨")
assert(#notes == 1, "안내가 한 번 있어야 함")
assert(notes[1].level == vim.log.levels.WARN, "WARN 수준이어야 함")
assert(notes[1].msg:find("jdtls", 1, true), "안내에 jdtls가 있어야 함")

vim.fn.executable = function()
  return 1
end
dofile("ftplugin/java.lua")
assert(started == 1, "jdtls가 있으면 start_or_attach가 호출되어야 함")
os.exit(0)
