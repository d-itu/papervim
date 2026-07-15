---@diagnostic disable: missing-fields

local bit = require "bit"

local f = require 'core.format'
require "plugins.mini-icons"
local icons = require 'mini.icons'

vim.cmd.packadd "fzf-lua"

local fzf = require "fzf-lua"

local actions = require "fzf-lua.actions"

fzf.setup {
  winopts = {
    border = "none",
    preview = {
      border = "none",
    },
  },
  fzf_colors = { true },
  fzf_opts = {
    ["--prompt"] = " > "
  },
  hls = {
    preview_normal = "NormalNC",
  },
  grep = {
    actions = {
      ["ctrl-g"] = { actions.grep_lgrep },
      ["ctrl-r"] = { actions.toggle_ignore },
    },
  },
  previewers = {
    builtin = {
      render_markdown = { enabled = false },
      snacks_image = { enabled = false },
    },
  },
  files = {
    git_icons = true,
  },
}

vim.api.nvim_set_keymap("n", "\\ff", "", {
  callback = fzf.files,
  desc = "fzf file",
})
vim.api.nvim_set_keymap("n", "\\fw", "", {
  callback = fzf.live_grep,
  desc = "fzf file",
})

vim.keymap.set('n', 'grr', function()
  fzf.lsp_references {
    includeDeclaration = false
  }
end, { desc = "Lsp References" })
vim.keymap.set('n', 'gri', fzf.lsp_implementations, { desc = "Lsp References" })

local builtin = require("fzf-lua.previewer.builtin")
local dir_previewer = builtin.base:extend()

function dir_previewer:new(o, opts)
  self.super.new(self, o, opts)
  setmetatable(self, self.super)
  return self
end

function dir_previewer:gen_winopts()
  local winopts = {
    wrap = true,
    number = false,
    relativenumber = false,
    winhighlight = "FloatBorder:FzfLuaPreviewBorder,NormalFloat:NormalNC,Normal:NormalNC",
  }
  return vim.tbl_extend("keep", winopts, self.winopts)
end

local ffi = require "ffi"
ffi.cdef [[
  struct dirent {
    unsigned long ino;
    long off;
    unsigned short reclen;
    unsigned char type;
    char name[256];
  };
  void *opendir(const char*);
  struct dirent *readdir(void *);
  int closedir(const char*);
]]
local nullptr = ffi.cast("void *", 0);

local file_type = {
  [1] = 'p',
  [2] = 'c',
  [4] = 'd',
  [6] = 'b',
  [8] = '-',
  [10] = 'l',
  [12] = 's',
  [14] = 'w',
}
---@param x integer
---@return string
local function format_mode(x)
  return f("{}{}{}{}{}{}{}{}{}",
    bit.band(x, 0b100000000) == 0 and "-" or "r",
    bit.band(x, 0b010000000) == 0 and "-" or "w",
    bit.band(x, 0b001000000) == 0 and "-" or "x",
    bit.band(x, 0b000100000) == 0 and "-" or "r",
    bit.band(x, 0b000010000) == 0 and "-" or "w",
    bit.band(x, 0b000001000) == 0 and "-" or "x",
    bit.band(x, 0b000000100) == 0 and "-" or "r",
    bit.band(x, 0b000000010) == 0 and "-" or "w",
    bit.band(x, 0b000000001) == 0 and "-" or "x"
  )
end

---@param s string?
local function format_link(s)
  return s and { { " -> ", "Comment" }, { s, "@markup.link" } } or {}
end

local units = { 'K', 'M', 'G', 'T', 'P', 'E' }
local function format_size(x)
  if x <= 1024 then return ("%7d"):format(x) end
  local p = math.min(math.floor(math.log(x, 1024)), 6)
  local n = x / math.pow(1024, p)
  return ("%6.1f%s"):format(n, units[p])
end

---@param s integer
---@return string
local function format_duration(s)
  local m = s / 60
  if m < 1 then return "now" end
  local h = m / 60
  if h < 1 then return ("%d min"):format(m) end
  local d = h / 24
  if d < 1 then return ("%d hr"):format(h) end
  local m = d / 30
  if m < 1 then return ("%d d"):format(h) end
  local y = d / 365.2
  if y < 1 then return ("%d mo"):format(m) end
  return ("%d yr"):format(y)
end

---@class entry
---@field name string
---@field name_hl string
---@field icon string
---@field icon_hl string
-- ---@field link string?
---@field virt_text [string, string?][]

---@param buf integer
---@param ns integer
local function brush(buf, ns)
  local line = 0
  local col = 0
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " " })
  return {
    ---@param text string
    append = function(text)
      vim.api.nvim_buf_set_text(buf, line, -1, line, -1, { text })
      col = col + #text
    end,
    ---@param text string
    ---@param hl string
    append_with_hl = function(text, hl)
      vim.api.nvim_buf_set_text(buf, line, -1, line, -1, { text })
      vim.api.nvim_buf_set_extmark(buf, ns, line, col + 1, {
        end_col = -1,
        strict = false,
        hl_group = hl,
      })
      col = col + #text
    end,
    new_line = function()
      line = line + 1
      vim.api.nvim_buf_set_lines(buf, line, -1, false, { " " })
      col = 0
    end
  }
end

---@param buf integer
---@param dir_path string
local function render_dir(buf, dir_path)
  local dir = ffi.C.opendir(dir_path)
  if dir == nullptr then return end
  ---@type entry[]
  local entries = {}
  local name_cols = 0
  -- local link_cols = 0
  local now = vim.fn.localtime()
  while true do
    local entry = ffi.C.readdir(dir)
    if entry == nullptr then break end
    local name = ffi.string(entry.name)
    if name == '.' or name == '..' then goto continue end
    name_cols = math.max(name_cols, vim.fn.strdisplaywidth(name))
    local path = vim.fs.joinpath(dir_path, name)
    local stat = vim.uv.fs_stat(path)
    if not stat then goto continue end
    local icon, icon_hl = "?", "Normal"
    if stat.type == "directory" or stat.type == "file" then
      icon, icon_hl = icons.get(stat.type, name)
    end
    local link = nil
    local ft = file_type[entry.type]
    if ft == "l" then
      link = vim.uv.fs_readlink(path)
    end
    ---@type entry
    local entry = {
      icon = icon,
      icon_hl = icon_hl,
      name = name,
      name_hl = stat.type == "directory" and "Directory" or "Normal",
      virt_text = {
        { ft,                                                          "Comment" },
        { format_mode(stat.mode),                                      "Comment" },
        { "  " },
        { format_size(stat.size),                                      "Comment" },
        { string.format("%7s", format_duration(now - stat.mtime.sec)), "Comment" },
        unpack(format_link(link))
      }
    }
    table.insert(entries, entry)
    ::continue::
  end
  ffi.C.closedir(dir)

  table.sort(entries, function(x, y)
    return x.name < y.name
  end)

  local ns = vim.api.nvim_create_namespace("")
  local b = brush(buf, ns)
  for i, entry in ipairs(entries) do
    b.append_with_hl(entry.icon, entry.icon_hl)
    b.append " "
    b.append_with_hl(entry.name, entry.name_hl)

    vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
      hl_mode = "combine",
      virt_text = entry.virt_text,
      virt_text_win_col = name_cols + 5,
    })
    b.new_line();
  end
end

---@async
---@param entry string
---@return false? -- no preview
function dir_previewer:populate_preview_buf(entry)
  local buf = self:get_tmp_buffer()
  render_dir(buf, entry)
  self:set_preview_buf(buf)
end

fzf.register_ui_select()
