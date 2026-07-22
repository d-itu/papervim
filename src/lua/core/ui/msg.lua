local utils = require "core.ui.utils"
local f = require "core.format"

local showcmd = ""

---@diagnostic disable-next-line: duplicate-set-field
function _G.showcmd()
  return showcmd
end

---@class item
---@field buf integer
---@field win integer
---@field timer uv.uv_timer_t
---@field line integer
---@field height integer

---@alias kind ""
--- | "empty"
--- | "confirm"
--- | "emsg"
--- | "echo"
--- | "echoerr"
--- | "completion"
--- | "list_cmd"
--- | "lua_error"
--- | "lua_print"
--- | "progress"
--- | "quickfix"
--- | "rpc_error"
--- | "search_cmd"
--- | "search_count"
--- | "shell_cmd"
--- | "shell_err"
--- | "undo"
--- | "verbose"
--- | "wildlist"
--- | "wmsg"

---@alias trigger "" | "typed_cmd"

local bg = {
  emsg = "Error",
  echoerr = "Error",
  lua_error = "Error",
  rpc_error = "Error",
  shell_err = "Error",
  wmsg = "Warn",
  progress = "Ok"
}

local header = "▌"
local header_width = vim.fn.strdisplaywidth(header)

local timeout = 3500
local max_width = 65
local max_height = 30

---@type table<integer | string, item>
local storage = {}

local line_available = {}
---@param height integer
---@return integer
local function alloc_line(height)
  if height >= max_height then return 1 end
  local line = 1
  while line < max_height do
    local is_free = true
    for i = line, line + height - 1 do
      if line_available[i] then
        is_free = false
        break
      end
    end
    if is_free then
      for i = line, line + height - 1 do
        line_available[i] = true
      end
      return line
    end
    line = line + height
  end

  line_available = {}
  return alloc_line(height)
end

---@param height integer
---@param line integer
local function dealloc_line(line, height)
  for i = line, line + height - 1 do
    line_available[i] = nil
  end
end

---@param id integer | string
---@param force boolean
local function delete_item(id, force)
  local item = storage[id]
  if not item then return end
  if force or vim.api.nvim_get_current_win() ~= item.win then
    if vim.api.nvim_win_is_valid(item.win) then
      vim.api.nvim_win_close(item.win, true)
    end
    if vim.api.nvim_buf_is_valid(item.buf) then
      vim.api.nvim_buf_delete(item.buf, { force = true })
    end
    item.timer:close()
    dealloc_line(item.line, item.height)
    storage[id] = nil
    if vim.tbl_isempty(storage) then storage = {} end
  else
    item.timer:stop()
    item.timer:start(timeout, 0, function()
      vim.schedule(function() delete_item(id, false) end)
    end)
  end
end

---@param id integer | string
---@param content content_entry[]
---@param kind kind
---@param history boolean
local function update(id, content, kind, history)
  local text = utils.concat_content(content)
  local lines = vim.split(text, "\n", {})
  if storage[id] then delete_item(id, true) end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  if kind == "lua_print" then
    vim.api.nvim_set_option_value("filetype", "lua", { buf = buf })
  end
  utils.cursor(buf).render(content)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  local width = vim.iter(lines):map(vim.fn.strdisplaywidth):fold(1, math.max)

  local height = #lines
  local line = alloc_line(height)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    anchor = "SE",
    width = math.min(width, max_width) + header_width,
    height = height,
    row = vim.go.lines - line,
    col = vim.go.columns,
    style = "minimal",
    zindex = 300,
  })
  local kind_bg = bg[kind] or (history and "Info" or "Hint")
  vim.api.nvim_set_option_value("winhighlight", "Normal:DiagnosticVirtualText" .. kind_bg, {
    win = win,
    scope = "local",
  })
  vim.api.nvim_set_option_value("statuscolumn", f("%#Diagnostic{}#{}", kind_bg, header), { win = win })

  local timer = assert(vim.uv.new_timer())
  timer:start(timeout, 0, function()
    vim.schedule(function() delete_item(id, false) end)
  end)
  storage[id] = {
    buf = buf,
    win = win,
    timer = timer,
    height = height,
    line = line,
  }
end

local search_count
local search_count_buf

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "hlsearch",
  callback = function()
    if not vim.go.hlsearch and search_count and vim.api.nvim_buf_is_loaded(search_count_buf) then
      vim.api.nvim_buf_del_extmark(search_count_buf, utils.ns, search_count)
    end
  end,
  group = require "core.augroup"
})

return {
  ---@param kind kind
  ---@param content content_entry[]
  ---@param _replace_last boolean
  ---@param history boolean
  ---@param _append boolean
  ---@param id integer | string
  ---@param _trigger trigger
  msg_show = function(kind, content, _replace_last, history, _append, id, _trigger)
    if kind == "search_cmd" then return end
    if kind == "search_count" then
      vim.schedule(function()
        vim.go.hlsearch = true
        search_count_buf = vim.api.nvim_get_current_buf()
        search_count = vim.api.nvim_buf_set_extmark(0, utils.ns, vim.api.nvim_win_get_cursor(0)[1] - 1, 0, {
          virt_text = { { content[1][2], { "DiagnosticVirtualTextInfo" } } },
          id = search_count
        })
      end)
      return
    end
    if kind == "list_cmd" then
      vim.schedule(function()
        local buf = utils.float()
        utils.cursor(buf).render(content)
        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
      end)
      return
    end
    if kind == "empty" then return end
    if kind == "" then return end

    vim.schedule(function()
      update(id, content, kind, history)
    end)
  end,
  ---@param content content_entry[]
  msg_showcmd = function(content)
    showcmd = utils.concat_content(content)
    vim.api.nvim__redraw { statusline = true, flush = true, win = 0 }
  end,
  ---@param entries [kind, content_entry[], boolean][]
  ---@param prev_cmd boolean
  msg_history_show = function(entries, prev_cmd)
    if prev_cmd then
      local kind, content, _ = unpack(entries[1])
      if kind == "empty" then return end

      update(0, content, kind, false)
    else
      local buf = utils.float()
      vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
      local cursor = utils.cursor(buf)
      for _, entry in ipairs(entries) do
        local kind, content, _ = unpack(entry)
        vim.api.nvim_buf_set_extmark(buf, utils.ns, cursor.row(), cursor.col(), {
          virt_text = { { kind, "LspInlayHint" } },
          virt_text_pos = "right_align",
        })
        cursor.render(content)
        cursor.append("\n")
      end
      vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    end
  end,
}
