local ui = require "papervim.picker.ui"

---@class picker.stream.basic.opts
---@field prompt string?
---@field on_choice fun(idx?: integer)
---@field new_stream fun(picker: picker):uv.uv_stream_t?
---@field on_read fun(err?: string, data?: string, picker: picker, outdated:fun():boolean)
---@field use_preview_win? boolean
---@field preview fun(idx?: integer, win?: integer)
---@field cancel fun()

---@class picker.stream: picker
local picker = setmetatable({}, ui.picker)
picker.__index = picker

---@param opts picker.stream.basic.opts
local basic = function(opts)
  local serial = 0

  ---@param picker picker
  local start = function(picker)
    serial = serial + 1
    opts.cancel()
    local stream = opts.new_stream(picker)
    if not stream then return end
    stream:read_start(function(err, data)
      local token = serial
      opts.on_read(err, data, picker, function() return token ~= serial end)
    end)
  end

  local super = ui.show {
    prompt = opts.prompt,
    on_input_changed = start,
    use_preview_win = opts.use_preview_win,
    preview = opts.preview,
    on_choice = function(idx)
      serial = 0
      opts.cancel()
      opts.on_choice(idx)
    end,
  }

  ---@class picker.stream
  local this = setmetatable(super, picker)
  this.start = start
  return this
end

---@generic T
---@class picker.stream.opts<T>
---@field prompt string?
---@field on_choice fun(item?: T)
---@field new_stream fun(picker: picker):uv.uv_stream_t?
---@field iter fun(data: string): fun():T
---@field render fun(item?: T, buf: integer, row: integer)
---@field use_preview_win? boolean
---@field preview fun(item?: T, win?: integer)
---@field cancel fun()

---@param opts picker.stream.opts
local show = function(opts)
  local items = {}

  local init

  return basic {
    prompt = opts.prompt,
    cancel = opts.cancel,
    new_stream = function(picker)
      local stream = opts.new_stream(picker)
      if not stream then
        items = {}
        picker:set_label {}
        vim.bo[picker.list.buf].modifiable = true
        vim.api.nvim_buf_set_lines(picker.list.buf, 0, -1, false, {})
        vim.bo[picker.list.buf].modifiable = false
        opts.preview(nil, picker.preview_win)
        return
      end
      init = true
      return stream
    end,
    on_read = function(_err, data, picker, outdated)
      vim.schedule(function()
        if outdated() then return end

        vim.bo[picker.list.buf].modifiable = true

        if init then
          items = {}
          vim.api.nvim_buf_set_lines(picker.list.buf, 0, -1, false, {})
        end

        if not data then
          picker:set_label { { tostring(#items), "NonText" } }
        else
          for item in opts.iter(data) do
            if outdated() then break end
            opts.render(item, picker.list.buf, #items)
            table.insert(items, item)
          end
          vim.api.nvim__redraw {
            buf = picker.list.buf,
            flush = true,
          }
          picker:set_label { { "* " .. tostring(#items), "NonText" } }
          if init then
            local idx = picker:selected()
            opts.preview(idx and items[idx], picker.preview_win)
          end
          init = false
        end

        vim.bo[picker.list.buf].modifiable = false
      end)
    end,
    use_preview_win = opts.use_preview_win,
    preview = function(idx, win)
      opts.preview(idx and items[idx], win)
    end,
    on_choice = function(idx)
      opts.on_choice(idx and items[idx])
    end,
  }
end

return {
  basic = basic,
  show = show,
}
