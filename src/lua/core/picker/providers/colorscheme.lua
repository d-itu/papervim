local fuzzy = require "core.picker.fuzzy"

return function()
  local original_color = vim.g.colors_name or "default"
  local original_background = vim.o.background

  local items = { original_color }
  for _, color in ipairs(vim.fn.getcompletion('', 'color')) do
    if color ~= original_color then
      table.insert(items, color)
    end
  end

  fuzzy.show(items, {
    format = tostring,
    preview = function(idx)
      vim.o.background = original_background
      local color = idx and items[idx] or original_color
      if color ~= vim.g.colors_name then
        vim.schedule(function() vim.cmd.colorscheme(color) end)
      end
    end,
    on_choice = function(res)
      if not res and (vim.g.colors_name ~= original_color or vim.o.background ~= original_background) then
        vim.schedule(function() vim.cmd.colorscheme(original_color) end)
      end
    end,
  })
end
