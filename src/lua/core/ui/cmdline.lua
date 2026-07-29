local utils = require "core.ui.utils"

local buf = vim.api.nvim_create_buf(false, true)

---@type integer?
local win

---@return integer
local function get_win()
  if not win then
    win = vim.api.nvim_open_win(buf, false, {
      relative = 'editor',
      row = vim.go.lines,
      col = 0,
      width = vim.go.columns,
      height = 1,
      style = "minimal",
    })
  end
  return win
end

local offset = 0
local prompt_mark
local last_prompt
local last_confirm

return {
  ---@param content content_entry[]
  ---@param pos integer cursor position
  ---@param firstc string
  ---@param prompt string
  ---@param indent integer
  ---@param _level integer
  ---@param hl integer highlight of prompt
  cmdline_show = function(content, pos, firstc, prompt, indent, _level, hl)
    local confirm = utils.confirm_msg.take()
    if confirm then last_confirm = confirm end
    if not confirm and prompt ~= last_prompt then
      last_confirm = nil
    end
    last_prompt = prompt

    local win = get_win()

    ---@type [string, integer | string][]
    local prompt_virt_text
    local prefix = ""
    if firstc == ":" then
      vim.api.nvim_set_option_value("filetype", "vim", { buf = buf })
      local text = utils.concat_content(content)
      local is_lua = text:match "^%s*lua%s+" or text:match "^%s*luado%s+" or text:match "^%s*="
      prompt_virt_text = { is_lua and { "  ", "MiniIconsGreen" } or { "  ", "MiniIconsCyan" } }
    elseif firstc == "=" then
      vim.api.nvim_set_option_value("filetype", "vim", { buf = buf })
      prompt_virt_text = { { "  ", "MiniIconsCyan" } }
      prefix = "="
    else
      vim.api.nvim_set_option_value("filetype", "", { buf = buf })
      vim.treesitter.stop(buf)

      local confirm = last_confirm or {}
      prompt_virt_text = vim.tbl_map(function(entry)
        local _, text, hl = unpack(entry)
        return { text, hl }
      end, confirm)
      if #confirm ~= 0 then
        table.insert(prompt_virt_text, { " ", 0 })
      end
      table.insert(prompt_virt_text, { firstc == "" and prompt or firstc, hl })
    end

    local prefix_len = vim.fn.strdisplaywidth(prefix)
    offset = vim.iter(prompt_virt_text):fold(indent + prefix_len, function(acc, entry)
      return acc + vim.fn.strdisplaywidth(entry[1])
    end)

    local cursor = utils.cursor(buf)
    cursor.append((' '):rep(offset - prefix_len))
    cursor.append(prefix)
    cursor.render(content)
    cursor.append ' '
    prompt_mark = vim.api.nvim_buf_set_extmark(buf, utils.ns, 0, 0, {
      virt_text = prompt_virt_text,
      virt_text_pos = "overlay",
      id = prompt_mark,
    })
    vim.api.nvim_win_set_cursor(win, { 1, pos + offset })
    vim.api.nvim__redraw {
      win = win,
      cursor = true,
      flush = true,
    }
  end,
  ---@param pos integer
  ---@param _level integer
  cmdline_pos = function(pos, _level)
    if win then
      vim.api.nvim_win_set_cursor(win, { 1, pos + offset })
      vim.api.nvim__redraw {
        win = win,
        cursor = true,
      }
    end
  end,
  ---@param _level integer
  ---@param _abort boolean
  cmdline_hide = function(_level, _abort)
    if win then
      vim.api.nvim_win_hide(win)
      win = nil
    end
  end,
  ---@param _lines content_entry[][]
  cmdline_block_show = function(_lines) end,
  ---@param _line content_entry[]
  cmdline_block_append = function(_line) end,
  cmdline_block_hide = function() end,
}
