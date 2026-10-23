if vim.g.colors_name then
  vim.cmd "hi clear"
  vim.cmd "syntax reset"
end

vim.g.colors_name = "mygo"
vim.o.background = "dark"

local palette = {
  tomori = 0x77bbdd,
  anon = 0xff8899,
  rana = 0x77dd77,
  soyo = 0xffdd88,
  taki = 0x7777aa,

  uika = 0xbb9955,
  mutsumi = 0x779977,
  umiri = 0x335566,
  nyamu = 0xaa4477,
  sakiko = 0x7799cc,

  mygo = 0x3388bb,
  ave_mujica = 0x881144,
}

local mix = require "papervim.ui.utils".mix

local grey = {
  dark = {
    mix(0, palette.mygo, 0.12),
    mix(0, palette.mygo, 0.16),
    mix(0, palette.mygo, 0.24),
    mix(0, palette.mygo, 0.38),
    mix(0, palette.mygo, 0.71),
  },
  light = {
    mix(0xffffff, palette.mygo, 0.1),
    mix(0xffffff, palette.mygo, 0.3),
    mix(0xffffff, palette.mygo, 0.5),
    mix(0xffffff, palette.mygo, 0.7),
  },
}

local inactive = mix(grey.dark[4], grey.light[2], 0.78)

require "papervim.colorscheme".set_hl {
  search = { fg = grey.light[1], bg = palette.uika },
  cur_search = { fg = grey.dark[1], bg = palette.soyo },
  substitute = { fg = palette.anon, bg = palette.nyamu },
  status_line = { fg = inactive, bg = grey.dark[3] },
  status_line_nc = { fg = inactive, bg = grey.dark[2] },
  win_bar = { fg = inactive },
  win_bar_nc = { fg = inactive },
  tabline = {
    fg = inactive,
    bg = grey.dark[3],
    sel = grey.dark[2],
    fill = grey.dark[3],
  },
  match_paren = { bg = mix(palette.ave_mujica, grey.dark[4], 0.63), fg = palette.ave_mujica },
  inlay_hint = { fg = grey.dark[5], bg = grey.dark[3] },
  todo = { bold = true, fg = palette.soyo, bg = palette.uika },

  diff = {
    added = { fg = palette.tomori, bg = palette.umiri },
    changed = { fg = palette.soyo, bg = palette.uika },
    removed = { fg = palette.anon, bg = palette.nyamu },
  },
  diagnostic = {
    error = { fg = palette.anon, bg = mix(grey.dark[2], palette.nyamu, 0.45) },
    warn = { fg = palette.soyo, bg = mix(grey.dark[2], palette.uika, 0.35) },
    info = { fg = palette.tomori, bg = mix(grey.dark[2], palette.sakiko, 0.25) },
    hint = { fg = palette.taki, bg = mix(grey.dark[2], palette.umiri, 0.25) },
    ok = { fg = palette.mutsumi, bg = mix(grey.dark[2], palette.mutsumi, 0.18) },
  },
  menu = {
    bg = grey.dark[3],
    kind = palette.taki,
    extra = palette.mygo,
    match = palette.anon,
    sel = grey.dark[4],
    thumb = grey.dark[4],
  },
  spell = {
    bad = palette.mygo,
    cap = palette.uika,
    rare = palette.anon,
    ["local"] = palette.rana,
  },
  markup = {
    raw = palette.tomori,
    list = palette.sakiko,
    checked = palette.tomori,
    unchecked = inactive,
  },
  symbols = {
    boolean = { fg = palette.taki, bold = true, italic = true },
    number = { fg = palette.soyo },
    string = { link = "Character" },
    character = { fg = palette.soyo },
    constant = { fg = palette.soyo },
    label = { fg = palette.rana, italic = true },
    keyword = { fg = palette.taki },
    macro = { fg = palette.rana, italic = true, bold = true },
    attribute = { fg = palette.rana },
    type = { fg = palette.soyo },
    variable = { italic = true },
    ["function"] = { fg = palette.anon, italic = true },
    member = { fg = palette.tomori, italic = true },
    parameter = { fg = grey.light[2], italic = true },
    tag = { fg = palette.taki, italic = true },
    comment = { fg = palette.mygo, italic = true },
    operator = { fg = palette.sakiko },
    delimiter = { fg = palette.sakiko },
    constructor = { fg = palette.sakiko },
    module = { fg = palette.taki, italic = true, },
    path = { fg = palette.soyo },
    concept = { fg = palette.anon },
    lifetime = { fg = palette.rana },
    component = { fg = palette.soyo },
    escape = { fg = palette.rana },
    regex = { fg = palette.anon },
    self = { fg = palette.taki, bold = true, italic = true },
    self_type = { bold = true },
  },
  colors = {
    white = grey.light[1],
    red = palette.anon,
    orage = palette.uika,
    yellow = palette.soyo,
    green = palette.mutsumi,
    azure = palette.tomori,
    blue = palette.mygo,
    cyan = palette.sakiko,
    purple = palette.taki,
    grey = grey.light[3],
  },
  ansi = {
    grey.dark[4],
    palette.nyamu,
    palette.mutsumi,
    palette.uika,
    palette.umiri,
    palette.taki,
    palette.sakiko,
    grey.light[3],

    grey.dark[5],
    palette.anon,
    palette.rana,
    palette.soyo,
    palette.mygo,
    palette.taki,
    palette.tomori,
    grey.light[2],
  },
  fg = {
    normal = grey.light[2],
    inactive = inactive,
    non_text = grey.dark[5],
    special = palette.rana,
    directory = palette.taki,
    mode_msg = palette.soyo,
    more_msg = palette.taki,
    question = palette.taki,
    win_separator = palette.soyo,
    title = palette.tomori,
    cursor_line_nr = palette.ave_mujica,
    border = grey.dark[5],
  },
  bg = {
    normal = grey.dark[2],
    float = grey.dark[3],
    shadow = grey.dark[4],
    visual = mix(palette.ave_mujica, grey.dark[4], 0.63),
    cursor = palette.ave_mujica,
    cursor_line = grey.dark[4],
    color_column = palette.mutsumi,
    lsp_reference = grey.dark[5],
    title = palette.umiri,
  },
  custom = {
    BlinkCmpKindVariable = { fg = palette.tomori },
    DropBarIconKindDefault = { fg = palette.tomori },
  },
}
