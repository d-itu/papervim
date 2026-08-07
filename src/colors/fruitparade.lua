if vim.g.colors_name then
  vim.cmd "hi clear"
  vim.cmd "syntax reset"
end

vim.g.colors_name = "fruitparade"
vim.o.background = "dark"

---@enum fruitparade.palette
local palette = {
  grapefruit = '#e8959d',
  peach = '#f7bdb0',
  papaya = '#f5c689',
  lemon = '#f7ebb2',
  kiwi = '#b4db9c',
  lime = '#7be8dc',
  grape = '#8c83cc',
  blueberry = '#6cb4f5',

  cherry = '#f6abf7',
  dragon_fruit = '#e83180',
  coconut = '#ebe9e6',

  grey = '#99aacc',
  night = '#1e1c24',
  day = '#d3e1f2',
}

local mix = require "core.ui.utils".mix_color

local virtual_text = '#403c4d'

---@type groups.bg
local bg = {
  shadow = '#141317',
  float = '#18151f',
  normal = palette.night,
  cursor_line = '#302d3b',
  lsp_reference = '#4d485c',
  color_column = virtual_text,

  visual = mix(virtual_text, palette.dragon_fruit, 0.18),
  cursor = palette.dragon_fruit,
  title = mix(palette.night, palette.peach, 0.18),
}

local non_text = mix(bg.normal, palette.day, 0.48)

---@type groups.fg
local fg = {
  normal = palette.day,
  inactive = mix(bg.normal, palette.day, 0.88),
  non_text = non_text,
  special = palette.cherry,
  directory = palette.blueberry,
  mode_msg = palette.peach,
  more_msg = palette.blueberry,
  question = palette.cherry,
  win_separator = non_text,
  title = palette.peach,
  cursor_line_nr = palette.peach,
  border = non_text,
}

require "core.colorscheme".set_hl {
  search = { bg = mix(bg.normal, palette.papaya, 0.32) },
  cur_search = { fg = bg.shadow, bg = mix(bg.normal, palette.papaya, 0.9) },
  substitute = { fg = bg.shadow, bg = mix(bg.normal, palette.grapefruit, 0.9) },
  status_line = { fg = fg.inactive, bg = bg.float },
  status_line_nc = { fg = fg.inactive, bg = bg.float },
  win_bar = { fg = fg.inactive },
  win_bar_nc = { fg = fg.inactive },
  tabline = {
    fg = fg.inactive,
    bg = bg.float,
    sel = bg.normal,
    fill = bg.float,
  },
  match_paren = { bg = virtual_text, fg = palette.peach },
  inlay_hint = { fg = non_text, bg = virtual_text },
  todo = { bold = true, fg = bg.normal, bg = palette.peach },

  diff = {
    added = { fg = palette.lime, bg = mix(bg.normal, palette.lime, 0.2) },
    changed = { fg = palette.peach, bg = mix(bg.normal, palette.peach, 0.2) },
    removed = { fg = palette.grapefruit, bg = mix(bg.normal, palette.grapefruit, 0.2) },
  },
  diagnostic = {
    error = { fg = palette.peach, bg = mix(bg.normal, palette.peach, 0.2) },
    warn = { fg = palette.papaya, bg = mix(bg.normal, palette.papaya, 0.2) },
    info = { fg = palette.blueberry, bg = mix(bg.normal, palette.blueberry, 0.2) },
    hint = { fg = palette.grape, bg = mix(bg.normal, palette.grape, 0.2) },
    ok = { fg = palette.lime, bg = mix(bg.normal, palette.lime, 0.2) },
  },
  menu = {
    bg = bg.cursor_line,
    fg = fg.inactive,
    kind = palette.peach,
    extra = non_text,
    match = palette.peach,
    sel = virtual_text,
    thumb = virtual_text,
  },
  spell = {
    bad = palette.grey,
    cap = palette.papaya,
    rare = palette.lime,
    ["local"] = palette.grape,
  },
  markup = {
    raw = palette.peach,
    list = palette.blueberry,
    checked = palette.lime,
    unchecked = fg.inactive,
  },
  symbols = {
    boolean = { fg = palette.papaya },
    number = { fg = palette.papaya },
    string = { fg = palette.papaya },
    character = { fg = palette.kiwi },
    constant = { fg = palette.papaya },
    label = { fg = palette.cherry, italic = true },
    keyword = { fg = palette.grape },
    macro = { fg = palette.kiwi, italic = true, bold = true },
    attribute = { fg = palette.grapefruit },
    type = { fg = palette.peach },
    variable = { italic = true },
    ["function"] = { fg = palette.cherry, italic = true },
    member = { fg = palette.blueberry, italic = true },
    parameter = { fg = palette.lime, italic = true },
    tag = { fg = palette.lime, italic = true },
    comment = { fg = palette.grey, italic = true },
    operator = { fg = palette.grey },
    delimiter = { fg = palette.grey },
    constructor = { fg = palette.lime },
    module = { fg = palette.lemon, italic = true, },
    path = { fg = palette.lemon, underline = true },
    concept = { fg = palette.cherry },
    lifetime = { fg = palette.cherry, italic = true },
    component = { fg = palette.peach },
    escape = { fg = palette.cherry },
    regex = { fg = palette.lemon },
    self = { fg = palette.cherry, bold = true, italic = true },
    self_type = { bold = true },
  },
  colors = {
    white = palette.coconut,
    red = palette.grapefruit,
    orage = palette.peach,
    yellow = palette.lemon,
    green = palette.kiwi,
    azure = palette.blueberry,
    blue = palette.grape,
    cyan = palette.lime,
    purple = palette.cherry,
    grey = palette.grey,
  },
  ansi = {
    mix(0, palette.night, 0.35),
    palette.grapefruit,
    palette.kiwi,
    palette.papaya,
    palette.blueberry,
    palette.grape,
    palette.lime,
    palette.coconut,

    mix(0xc0c0c0, palette.night, 0.6),
    mix(0xc0c0c0, palette.grapefruit, 0.6),
    mix(0xc0c0c0, palette.kiwi, 0.6),
    mix(0xc0c0c0, palette.papaya, 0.6),
    mix(0xc0c0c0, palette.blueberry, 0.6),
    mix(0xc0c0c0, palette.grape, 0.6),
    mix(0xc0c0c0, palette.lime, 0.6),
    mix(0xc0c0c0, palette.coconut, 0.6),
  },
  fg = fg,
  bg = bg,
  custom = {
    PVModeNormal = { fg = bg.float, bg = palette.blueberry },
  },
}
