local ui = require "core.picker.ui"
local stream_ui = require "core.picker.stream"
local utils = require "core.utils"
local dir_previewer = require "core.picker.previewers.directory"

---@param path string?
---@return integer?, boolean?
local preview = function(path)
  if not path then return end
  if vim.fn.filereadable(path) == 1 then
    return ui.preview_file(path)
  end
  return dir_previewer.preview(path), true
end

---@class fd.args
---@field path string?
---@field hidden boolean?
---@field ignored boolean?

---@param args fd.args
local function show(args)
  if vim.fn.executable "fd" == 0 then vim.api.nvim_echo({ { "fd is not an executable" } }, true, { err = true }) end

  local cwd = vim.fn.getcwd(-1, -1)
  local dir = args.path
  if not dir or #dir == 0 then dir = cwd end
  dir = vim.fs.normalize(dir)

  ---@type uv.uv_pipe_t?
  local stream
  ---@type uv.uv_process_t?
  local proc

  local cancel = function()
    if proc then proc:kill "sigterm" end
    if stream then
      stream:read_stop()
      stream:close()
      stream = nil
    end
  end

  local number = vim.o.number
  local relativenumber = vim.o.relativenumber
  local picker = stream_ui.show {
    prompt = dir == "/" and dir or utils.substitute_home(dir) .. '/',
    cancel = cancel,
    new_stream = function(picker)
      local argv = {}
      if args.hidden then table.insert(argv, "-H") end
      if args.ignored then table.insert(argv, "-I") end
      table.insert(argv, "--")
      table.insert(argv, picker:get_input())

      stream = vim.uv.new_pipe()
      ---@diagnostic disable-next-line: missing-fields
      proc = vim.uv.spawn("fd", {
        args = argv,
        cwd = dir,
        stdio = { nil, stream, nil },
      }, function() end)
      return stream
    end,
    iter = function(data)
      return data:gmatch "[^\n]+"
    end,
    ---@param item string
    render = function(item, buf, row)
      dir_previewer.render_item(item, item:sub(#item, #item) == "/" and "directory" or "file", false, buf, row)
    end,
    use_preview_win = true,
    ---@param item string
    preview = function(item, win)
      if not win then return end
      local buf, not_file = preview(item)
      vim.api.nvim_win_set_buf(win, buf or require "core.empty_buf")
      if not_file then
        vim.wo[win].number = false
        vim.wo[win].relativenumber = false
      else
        vim.wo[win].number = number
        vim.wo[win].relativenumber = relativenumber
      end
    end,
    ---@param item string
    on_choice = function(item)
      if not item then return end
      local path = vim.fs.joinpath(dir, item)
      if vim.fn.isdirectory(path) == 1 then
        vim.schedule(function() show { path = path } end)
      else
        vim.cmd.edit(path)
      end
    end,
  }

  local function set_win_bar()
    picker:show_flags {
      hidden = args.hidden or false,
      ignored = args.ignored or false,
    }
  end

  set_win_bar()
  local function show_hidden()
    args.hidden = not args.hidden
    set_win_bar()
    picker:start()
  end
  local function show_ignored()
    args.ignored = not args.ignored
    set_win_bar()
    picker:start()
  end

  vim.api.nvim_buf_set_keymap(picker.prompt.buf, "n", "", "", { callback = show_hidden })
  vim.api.nvim_buf_set_keymap(picker.prompt.buf, "i", "", "", { callback = show_hidden })
  vim.api.nvim_buf_set_keymap(picker.prompt.buf, "n", "<C-g>", "", { callback = show_ignored })
  vim.api.nvim_buf_set_keymap(picker.prompt.buf, "i", "<C-g>", "", { callback = show_ignored, nowait = true })
end

return show
