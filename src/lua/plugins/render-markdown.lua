local is_tty = require "core.ttymode"

if is_tty then return end

-- require "plugins.image"

vim.cmd.packadd "render-markdown.nvim"
require "render-markdown".setup {
  heading = {
    icons = function(ctx)
      return table.concat(ctx.sections, ".") .. " "
    end
  },
  code = {
    border = 'thin',
  },
  bullet = {
    icons = { "", "" },
    ordered_icons = function(ctx)
      local levels = {
        {
          '\u{f0b3a}',
          '\u{f0b3b}',
          '\u{f0b3c}',
          '\u{f0b3d}',
          '\u{f0b3e}',
          '\u{f0b3f}',
          '\u{f0b40}',
          '\u{f0b41}',
          '\u{f0b42}',
          '󰿩',
        },
        {
          '󰫶',
          '󱂉',
          '󱂊',
          '󱂋',
          '󰬃',
          '󱂍',
          '󱂎',
          '󱂏',
          '󱂐',
          '󰬅',
        },
        {
          '󱪼',
          '󱪽',
          '󱪾',
          '󱪿',
          '󱫀',
        },
      }
      local i = (ctx.level - 1) % #levels + 1
      local numbers = levels[i]
      local j = (ctx.index - 1) % #numbers + 1
      return ' ' .. numbers[j]
    end,
  },
  link = {
    footnote = {
      icon = "",
    },
  },
  sign = { enabled = false },
  completions = {
    blink = { enabled = true },
    lsp = { enabled = true },
  },
}
