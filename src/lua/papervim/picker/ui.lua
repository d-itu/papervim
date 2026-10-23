local group = require "papervim.augroup"

local ns = vim.api.nvim_create_namespace "picker"

---@class picker
local picker = {}
picker.__index = picker

---@param buf integer
local line_count = function(buf)
  local res = vim.api.nvim_buf_line_count(buf)
  if res == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "" then
    return 0
  end
  return res
end

local border = { "", "", "", "", " ", " ", " ", "" }

local margin = 0.08

---@class picker.rect
---@field col integer
---@field top integer
---@field width integer
---@field height integer

---@param opts picker.opts
local function show(opts)
  local prompt = opts.prompt or "> "

  ---@class picker
  local this = setmetatable({}, picker)

  local function make_config()
    local left = math.floor(vim.go.columns * margin)
    local top = math.floor(vim.go.lines * margin)
    local width = math.ceil(vim.go.columns * (1 - 2 * margin) * (opts.use_preview_win and 0.5 or 1))
    local height = math.ceil(vim.go.lines * (1 - 2 * margin))

    return {
      ---@type vim.api.keyset.win_config
      prompt = {
        relative = "editor",
        width = width,
        height = 1,
        col = left,
        row = top,
        style = "minimal",
      },
      ---@type vim.api.keyset.win_config
      list = {
        relative = "editor",
        width = width,
        height = height - (this.use_footer and 2 or 1),
        col = left,
        row = top + 1,
        style = "minimal",
        border = this.use_footer and border or "none",
      },
      ---@type vim.api.keyset.win_config
      preview = {
        relative = "editor",
        width = width,
        height = height,
        col = left + width,
        row = top,
        border = "none",
      },
    }
  end

  local configs = make_config()

  local prompt_buf = vim.api.nvim_create_buf(false, true)
  vim.fn.prompt_setprompt(prompt_buf, prompt)
  vim.bo[prompt_buf].bufhidden = "wipe"
  vim.bo[prompt_buf].buftype = "prompt"
  local prompt_win = vim.api.nvim_open_win(prompt_buf, true, configs.prompt)
  vim.wo[prompt_win].winfixbuf = true

  local list_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[list_buf].bufhidden = "wipe"
  vim.bo[list_buf].buftype = "nofile"
  vim.bo[list_buf].modifiable = false
  local list_win = vim.api.nvim_open_win(list_buf, false, configs.list)
  vim.wo[list_win].cursorline = true
  vim.wo[list_win].winfixbuf = true
  vim.wo[list_win].winhighlight = "WinBar:NormalFloat,WinBarNC:NormalFloat,FloatBorder:NormalFloat"

  ---@type integer?
  local preview_win
  if opts.use_preview_win then
    local empty_buf = require "papervim.empty_buf"
    preview_win = vim.api.nvim_open_win(empty_buf, false, configs.preview)
    vim.api.nvim_set_option_value('winhighlight', "WinBar:NormalFloat,WinBarNC:NormalFloat", {
      win = preview_win,
      scope = 'local',
    })
  end

  this.prompt = {
    buf = prompt_buf,
    win = prompt_win,
  }
  this.list = {
    buf = list_buf,
    win = list_win,
  }
  this.preview_win = preview_win
  this.done = false
  this.on_choice = opts.on_choice

  local resize = vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      local configs = make_config()
      vim.api.nvim_win_set_config(prompt_win, configs.prompt)
      vim.api.nvim_win_set_config(list_win, configs.list)
      if preview_win then vim.api.nvim_win_set_config(preview_win, configs.preview) end
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = { tostring(prompt_win), tostring(list_win), tostring(preview_win) },

    callback = function()
      pcall(vim.api.nvim_win_close, prompt_win, true)
      pcall(vim.api.nvim_win_close, list_win, true)
      vim.api.nvim_del_autocmd(resize)
      if preview_win then pcall(vim.api.nvim_win_close, preview_win, true) end
      this:abort()
    end,
    once = true,
  })

  local function do_preview()
    opts.preview(this:selected(), preview_win)
  end

  vim.api.nvim_create_autocmd("CursorMoved", {
    buf = list_buf,
    group = group,
    callback = do_preview,
  })

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buf = prompt_buf,
    group = group,
    callback = function()
      opts.on_input_changed(this)
    end,
  })

  local function prev()
    local count = line_count(list_buf)
    if count == 0 then return end
    local row = unpack(vim.api.nvim_win_get_cursor(list_win))
    vim.api.nvim_win_set_cursor(list_win, { row == 1 and count or row - 1, 0 })
    do_preview()
  end

  local function next()
    local count = line_count(list_buf)
    if count == 0 then return end
    local row = unpack(vim.api.nvim_win_get_cursor(list_win))
    vim.api.nvim_win_set_cursor(list_win, { row == count and 1 or row + 1, 0 })
    do_preview()
  end

  vim.api.nvim_buf_set_keymap(prompt_buf, "n", "<Down>", "", { callback = next })
  vim.api.nvim_buf_set_keymap(prompt_buf, "n", "j", "", { callback = next })
  vim.api.nvim_buf_set_keymap(prompt_buf, "i", "<Down>", "", { callback = next })
  vim.api.nvim_buf_set_keymap(prompt_buf, "n", "	", "", { callback = next })
  vim.api.nvim_buf_set_keymap(prompt_buf, "i", "	", "", { callback = next })
  vim.api.nvim_buf_set_keymap(prompt_buf, "n", "<Up>", "", { callback = prev })
  vim.api.nvim_buf_set_keymap(prompt_buf, "n", "k", "", { callback = prev })
  vim.api.nvim_buf_set_keymap(prompt_buf, "i", "<Up>", "", { callback = prev })
  vim.api.nvim_buf_set_keymap(prompt_buf, "n", "<S-Tab>", "", { callback = prev })
  vim.api.nvim_buf_set_keymap(prompt_buf, "i", "<S-Tab>", "", { callback = prev })

  local function abort() this:abort() end
  local function confirm() this:confirm() end

  vim.api.nvim_buf_set_keymap(prompt_buf, "n", "", "", { callback = abort, })
  vim.api.nvim_buf_set_keymap(list_buf, "n", "", "", { callback = abort, })
  vim.api.nvim_buf_set_keymap(prompt_buf, "n", "<CR>", "", { callback = confirm, })
  vim.api.nvim_buf_set_keymap(list_buf, "n", "<CR>", "", { callback = confirm, })

  vim.api.nvim_create_autocmd("TextChangedI", {
    buf = prompt_buf,
    group = group,
    callback = function()
      vim.api.nvim_buf_set_extmark(0, ns, 0, 0, {
        end_col = #prompt,
        hl_group = "Question",
        strict = false,
      })
    end,
    once = true,
  })

  vim.fn.prompt_setcallback(prompt_buf, function()
    this:confirm()
  end)

  vim.cmd.startinsert()

  return this
end

function picker:selected()
  return line_count(self.list.buf) ~= 0 and vim.api.nvim_win_get_cursor(self.list.win)[1] or nil
end

function picker:confirm()
  if self.done then return end
  self.done = true
  local idx = self:selected()
  pcall(vim.api.nvim_win_close, self.prompt.win, true)
  self.on_choice(idx)
end

function picker:abort()
  if self.done then return end
  self.done = true
  pcall(vim.api.nvim_win_close, self.prompt.win, true)
  self.on_choice()
end

function picker:get_input()
  return vim.fn.prompt_getinput(self.prompt.buf)
end

---@param virt_text [string, string | integer][]
function picker:set_label(virt_text)
  self.label = vim.api.nvim_buf_set_extmark(self.prompt.buf, ns, 0, 0, {
    virt_text = virt_text,
    virt_text_pos = "eol_right_align",
    id = self.label,
    priority = 200,
  })
end

---@param flags table<string, boolean>
function picker:show_flags(flags)
  local spans = {}
  for name, value in pairs(flags) do
    table.insert(spans, { " " .. name .. " ", value and "MsgInfo" or "LspInlayHint" })
    table.insert(spans, { " ", "NormalFloat" })
  end
  ---@type vim.api.keyset.win_config
  local config = {
    footer_pos = "center",
    footer = spans,
  }
  if not self.use_footer then
    config.height = vim.api.nvim_win_get_height(self.list.win) - 1
    config.border = border

    ---@private
    self.use_footer = true
  end
  vim.api.nvim_win_set_config(self.list.win, config)
end

---@alias picker.pair { index: integer, text: string }

---@class line_hl
---@field group integer | string
---@field begin integer
---@field end integer

---@alias picker.preview fun(index: integer?, preview_win: integer?) 1-based

---@class picker.opts
---@field on_choice fun(index: integer?) 1-based
---@field preview picker.preview
---@field on_input_changed fun(ctx: picker)
---@field prompt? string
---@field use_preview_win? boolean

return {
  picker = picker,
  show = show,
  ---@param name string
  ---@param filetype? string
  ---@return integer
  preview_file = function(name, filetype)
    local buf = vim.fn.bufnr(name)
    if buf ~= -1 then return buf end
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
    vim.api.nvim_buf_set_name(buf, name)
    -- TODO: binary file
    pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, vim.fn.readfile(name))
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

    local ft = filetype or vim.filetype.match { buf = buf }
    if ft then
      vim.api.nvim_set_option_value("filetype", ft, { buf = buf })
    end

    return buf
  end,
  ns = ns,
  ---@param buf integer
  ---@param row integer
  ---@param col? integer
  cursor = function(buf, row, col)
    local col = col or 0
    return {
      col = function() return col end,
      ---@param text string
      ---@param hl? integer | string
      append = function(text, hl)
        if col == 0 then
          vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { text })
        else
          vim.api.nvim_buf_set_text(buf, row, col, row, col, { text })
        end
        local end_col = col + #text
        if hl then
          vim.api.nvim_buf_set_extmark(buf, ns, row, col, {
            hl_group = hl,
            end_col = end_col,
          })
        end
        col = end_col
      end,
    }
  end,
}
