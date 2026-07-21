local log = assert(io.open("log", "w"))

return function(...)
  log:write(vim.inspect({ ... }, { newline = "" }) .. "\n")
  log:flush()
end
