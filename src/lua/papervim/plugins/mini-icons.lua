vim.cmd.packadd "mini.icons"
require "mini.icons".setup {
  filetype = {
    glsl   = { glyph = '', hl = 'MiniIconsCyan' },
    meson  = { glyph = '󱁤', hl = 'MiniIconsPurple' },
    kotlin = { glyph = '󱈙', hl = 'MiniIconsPurple' },
    dtd    = { glyph = '󰗀', hl = 'MiniIconsCyan' },
    cmake  = { glyph = '', hl = 'MiniIconsGreen' },
  },
  extension = {
    log = { glyph = '', hl = 'MiniIconsGrey' },
    out = { glyph = '', hl = 'MiniIconsRed' },
    o = { glyph = '', hl = 'MiniIconsRed' },
    a = { glyph = '', hl = 'MiniIconsGrey' },
    so = { glyph = '', hl = 'MiniIconsPurple' },
    db = { glyph = '󰆼', hl = 'MiniIconsYellow' },
    sqlite = { glyph = '', hl = 'MiniIconsBlue' },
  },
  file = {
    PKGBUILD = { glyph = '', hl = 'MiniIconsBlue' },
  },
  directory = {
    target = { glyph = '󱧼', hl = 'MiniIconsYellow' },
    dist = { glyph = '󱧼', hl = 'MiniIconsYellow' },
    usr = { glyph = '󰉋', hl = 'MiniIconsAzure' },
  },
}
