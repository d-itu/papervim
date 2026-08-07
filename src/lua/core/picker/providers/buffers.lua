local fuzzy = require "core.picker.fuzzy"
local ui = require "core.picker.ui"
local icons = require "core.icons"

return function()
  local cwd = vim.fn.getcwd(-1, -1)

  local items = vim.iter(vim.api.nvim_list_bufs()):map(function(buf)
    return {
      buf = buf,
      name = vim.api.nvim_buf_get_name(buf),
      filetype = vim.bo[buf].filetype,
      buftype = vim.bo[buf].buftype,
      modified = vim.bo[buf].modified,
      modifiable = vim.bo[buf].modifiable,
      listed = vim.bo[buf].buflisted,
    }
  end):totable()

  fuzzy.show(items, {
    format = function(item)
      local name = item.name
      return name:sub(1, #cwd) == cwd and "./" .. name:sub(#cwd + 2) or name
    end,
    use_preview_win = true,
    preview = function(idx, win)
      if not win then return end
      if not idx then
        vim.api.nvim_win_set_buf(win, require "core.empty_buf")
        return
      end

      local item = items[idx]
      if vim.api.nvim_buf_is_loaded(item.buf) then
        vim.api.nvim_win_set_buf(win, item.buf)
        return
      end
      local temp_buf = vim.api.nvim_create_buf(false, true)
      vim.bo[temp_buf].bufhidden = 'wipe'
      vim.api.nvim_buf_set_lines(temp_buf, 0, -1, false, {
        vim.api.nvim_buf_is_valid(item.buf) and "not loaded" or "invalid"
      })

      vim.api.nvim_win_set_buf(win, temp_buf)
    end,
    render = function(fuzzy_item, matches, list_buf, row)
      local cursor = ui.cursor(list_buf, row)

      local item = items[fuzzy_item.index]

      cursor.append(tostring(item.buf), item.listed and "Number" or "NonText")
      cursor.append ' '

      if #item.filetype ~= 0 then
        local icon, hl, is_default = icons.get('filetype', item.filetype)
        if not is_default then
          cursor.append(icon, hl)
        else
          cursor.append(item.filetype, 'NonText')
        end
        cursor.append ' '
      end

      local offset = cursor.col()
      cursor.append(#fuzzy_item.text == 0 and "[No Name]" or fuzzy_item.text)
      fuzzy.highlight_matched(item.text, matches, offset, list_buf, row)

      if item.modified then
        cursor.append(" ", "Changed")
      end
      if not item.modifiable then
        cursor.append(" ", "NonText")
      end
      cursor.append ' '

      cursor.append(item.buftype, 'Type')
    end,
    on_choice = function() end,
  })
end
