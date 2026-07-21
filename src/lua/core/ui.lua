local utils = require "core.ui.utils"

local listeners = vim.tbl_extend("error", unpack {
  require "core.ui.cmdline",
  require "core.ui.msg",
})

vim.ui_attach(utils.ns, {
  ext_cmdline = true,
  ext_messages = true,
}, function(event, ...)
  local callback = listeners[event]
  if callback then callback(...) end
end)
