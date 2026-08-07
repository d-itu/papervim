local icons = require "core.icons"

local ui = require "core.picker.ui"
local stream_ui = require "core.picker.stream"

---@class rg.item
---@field path string
---@field line integer
---@field col { start: integer, end: integer }
---@field text string

---@class rg.args
---@field hidden boolean?
---@field ignored boolean?

---@param args rg.args
return function(args)
  if vim.fn.executable "rg" == 0 then vim.api.nvim_echo({ { "rg is not an executable" } }, true, { err = true }) end

  ---@type uv.uv_pipe_t?
  local stream
  ---@type uv.uv_process_t?
  local proc

  ---@type { buf: integer, id: integer }?
  local last_hl
  local function clear_last_hl()
    if last_hl then
      pcall(vim.api.nvim_buf_del_extmark, last_hl.buf, ui.ns, last_hl.id)
    end
  end

  local picker = stream_ui.show {
    cancel = function()
      if proc then proc:kill "sigterm" end
      if stream then
        stream:read_stop()
        stream:close()
        stream = nil
      end
    end,
    new_stream = function(picker)
      local input = picker:get_input()
      if #input == 0 then return end

      local argv = {}
      table.insert(argv, "--json")
      table.insert(argv, "--smart-case")
      if args.hidden then table.insert(argv, "-.") end
      if args.ignored then table.insert(argv, "--no-ignore") end
      table.insert(argv, "--")
      table.insert(argv, input)

      stream = assert(vim.uv.new_pipe())
      ---@diagnostic disable-next-line: missing-fields
      proc = vim.uv.spawn("rg", {
        args = argv,
        stdio = { nil, stream, nil },
      }, function() end)
      return stream
    end,
    iter = function(data)
      ---@param line string
      ---@diagnostic disable-next-line: return-type-mismatch
      return vim.iter(data:gmatch "[^\n]+"):map(function(line)
        local ok, item = pcall(vim.json.decode, line)
        if not ok then return end
        if item.type ~= "match" then return end
        local data = item.data
        if not data.lines.text then return end
        return {
          path = data.path.text,
          line = data.line_number,
          col = data.submatches[1],
          text = data.lines.text
        }
      end)
    end,
    render = function(item, buf, row)
      local cursor = ui.cursor(buf, row)
      local icon, icon_hl = icons.get('file', item.path)
      cursor.append(icon, icon_hl)
      cursor.append ' '
      cursor.append(item.path)
      cursor.append ":"
      cursor.append(tostring(item.line))
      cursor.append ":"
      cursor.append(tostring(item.col.start))
      cursor.append ' '

      local text_start = cursor.col()
      cursor.append(item.text:sub(1, #item.text - 1), "NonText")

      vim.api.nvim_buf_set_extmark(buf, ui.ns, row, text_start + item.col.start, {
        end_col = text_start + item.col["end"],
        hl_group = "PmenuMatch",
      })
    end,
    use_preview_win = true,
    preview = function(item, win)
      clear_last_hl()
      if not win then return end
      if not item then
        vim.api.nvim_win_set_buf(win, require "core.empty_buf")
        return
      end
      local buf = ui.preview_file(item.path)
      last_hl = {
        buf = buf,
        id = vim.api.nvim_buf_set_extmark(buf, ui.ns, item.line - 1, item.col.start, {
          end_col = item.col["end"],
          hl_group = "CurSearch",
          strict = false,
        })
      }
      vim.api.nvim_win_set_buf(win, buf)
      pcall(vim.api.nvim_win_set_cursor, win, { item.line, item.col.start })
    end,
    on_choice = function(item)
      if not item then return end
      vim.cmd.edit(item.path)
      pcall(vim.api.nvim_win_set_cursor, 0, { item.line, item.col.start })
    end,
  }

  local function set_win_bar()
    picker:winbar_show_flags {
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
