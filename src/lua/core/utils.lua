local home = os.getenv "HOME"
local home_pattern = home and "^" .. home

return {
  ---@param path string
  substitute_home = function(path)
    if home_pattern then
      local result = path:gsub(home_pattern, "~", 1)
      return result
    end
    return path
  end,
}
