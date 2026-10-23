local ui = require "papervim.picker.ui"

---@generic T
---@class picker.fuzzy_opts<T>
---@field prompt? string
---@field format fun(item: T): string
---@field use_preview_win? boolean
---@field preview picker.preview
---@field on_choice fun(index?: integer)
---@field render? fun(fuzzy_item: fuzzy.item, matches: integer[], buf: integer, row: integer)

---@class fuzzy.item
---@field index integer
---@field text string

---@param text string
---@param matches integer[]
---@param offset integer
---@param buf integer
---@param row integer
local function highlight_matched(text, matches, offset, buf, row)
  for _, pos in ipairs(matches) do
    local col = vim.fn.byteidx(text, pos) + offset
    vim.api.nvim_buf_set_extmark(buf, ui.ns, row, col, {
      end_col = col + 1,
      hl_group = "PmenuMatch",
    })
  end
end

local default_render = function(item, matches, buf, row)
  vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { item.text })
  highlight_matched(item.text, matches, 0, buf, row)
end

---@generic T
---@param items T[]
---@param opts picker.fuzzy_opts
local function show(items, opts)
  local format = opts.format or tostring
  local render = opts.render or default_render

  ---@type fuzzy.item[]
  local fuzzy_items = vim.iter(items)
      :enumerate()
      :map(function(index, item)
        return {
          index = index,
          text = format(item),
        }
      end)
      :totable()

  local filtered = fuzzy_items

  ui.show {
    prompt = opts.prompt,
    use_preview_win = opts.use_preview_win,
    on_choice = function(idx)
      opts.on_choice(idx and filtered[idx].index)
    end,
    preview = function(idx, win)
      opts.preview(idx and filtered[idx].index, win)
    end,
    on_input_changed = function(ctx)
      local input = ctx:get_input()
      local buf = ctx.list.buf

      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
      if #input == 0 then
        filtered = fuzzy_items
        for i, item in ipairs(fuzzy_items) do
          render(item, {}, buf, i - 1)
        end
      else
        ---@type [fuzzy.item[], integer[][]]
        local result = vim.fn.matchfuzzypos(fuzzy_items, input, { key = "text" })
        local items, matches = unpack(result)
        filtered = items

        for i, item in ipairs(items) do
          render(item, matches[i], buf, i - 1)
        end
      end
      vim.bo[buf].modifiable = false

      ctx:set_label {
        { ("%d/%d"):format(#filtered, #fuzzy_items), "NonText" }
      }

      local selected = ctx:selected()
      opts.preview(selected and filtered[selected].index, ctx.preview_win)
    end,
  }
end

return {
  show = show,
  highlight_matched = highlight_matched,
}
