---@alias content_entry [_, string, integer]

local ns = vim.api.nvim_create_namespace("ui")

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

---@param content content_entry[]
---@return string
local function concat_content(content)
  return vim.iter(content):map(function(entry) return entry[2] end):join('')
end

local listeners = {
  ---@param content content_entry[]
  ---@param pos integer cursor position
  ---@param firstc string
  ---@param prompt string
  ---@param indent integer
  ---@param _level integer
  ---@param hl integer highlight of prompt
  cmdline_show = function(content, pos, firstc, prompt, indent, _level, hl)
    local win = get_win()

    local text = concat_content(content)

    ---@type [string, integer | string][]
    local prompt_virt_text
    local prefix = ""
    if firstc == ":" then
      vim.api.nvim_set_option_value("filetype", "vim", { buf = buf })
      local is_lua = text:match "%s*lua%s+" or text:match "%s*="
      prompt_virt_text = { is_lua and { "  ", "MiniIconsGreen" } or { "  ", "MiniIconsCyan" } }
    elseif firstc == "=" then
      vim.api.nvim_set_option_value("filetype", "vim", { buf = buf })
      prompt_virt_text = { { "  ", "MiniIconsCyan" } }
      prefix = "="
    else
      vim.api.nvim_set_option_value("filetype", "", { buf = buf })
      vim.treesitter.stop(buf)
      prompt_virt_text = { { firstc == "" and prompt or firstc, hl } }
    end

    local prefix_len = vim.fn.strdisplaywidth(prefix)
    offset = vim.iter(prompt_virt_text):fold(indent + prefix_len, function(acc, entry)
      return acc + vim.fn.strdisplaywidth(entry[1])
    end)

    local line = (' '):rep(offset - prefix_len) .. prefix .. text .. ' '
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { line })
    prompt_mark = vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
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

vim.ui_attach(ns, {
  ext_cmdline = true,
}, function(event, ...)
  local callback = listeners[event]
  if callback then callback(...) end
end)
