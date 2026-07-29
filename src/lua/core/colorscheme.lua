---@param value vim.api.keyset.highlight
---@return vim.api.keyset.highlight
local function bold(value)
  local result = vim.deepcopy(value, false)
  result.bold = true
  return result
end

---@param groups groups
local function set_hl(groups)
  ---@type table<string, vim.api.keyset.highlight>
  local values = {
    Search = groups.search,
    CurSearch = groups.cur_search,
    Visual = { bg = groups.bg.visual },

    NonText = { fg = groups.fg.non_text },
    Directory = { fg = groups.fg.directory, bold = true },
    ErrorMsg = { fg = groups.diagnostic.error.fg },
    Error = { fg = groups.diagnostic.error.fg },
    MoreMsg = { fg = groups.fg.more_msg },
    ModeMsg = { fg = groups.fg.mode_msg },

    LineNr = { link = 'NonText' },
    CursorLineNr = { fg = groups.fg.cursor_line_nr },

    Question = { fg = groups.fg.question },
    WinSeparator = { fg = groups.fg.win_separator },
    Title = { bold = true, fg = groups.fg.title },

    WarningMsg = { fg = groups.diagnostic.warn.fg },
    Folded = {},
    SignColumn = { fg = groups.fg.non_text },
    Conceal = { fg = groups.fg.non_text },

    SpellBad = { undercurl = true, special = groups.spell.bad },
    SpellCap = { undercurl = true, special = groups.spell.cap },
    SpellRare = { undercurl = true, special = groups.spell.rare },
    SpellLocal = { undercurl = true, special = groups.spell["local"] },

    Pmenu = { fg = groups.menu.fg, bg = groups.menu.bg },
    PmenuSel = { bg = groups.menu.sel },
    PmenuKind = { fg = groups.menu.kind },
    PmenuKindSel = { fg = groups.menu.kind, bg = groups.menu.sel },
    PmenuExtra = { fg = groups.menu.extra },
    PmenuExtraSel = { fg = groups.menu.extra, bg = groups.menu.sel },
    PmenuMatch = { fg = groups.menu.match },
    PmenuMatchSel = { fg = groups.menu.match, bg = groups.menu.sel },
    PmenuThumb = { bg = groups.menu.thumb },
    PmenuBorder = { fg = groups.fg.border },

    Normal = { fg = groups.fg.normal, bg = groups.bg.normal },
    NormalFloat = { bg = groups.bg.float },
    FloatBorder = { fg = groups.fg.border },

    WinBar = groups.win_bar,
    WinBarNC = groups.win_bar_nc,

    StatusLine = { fg = groups.status_line.fg, bg = groups.status_line.bg },
    StatusLineNC = { fg = groups.status_line_nc.fg, bg = groups.status_line_nc.bg },

    TabLine = { fg = groups.tabline.fg, bg = groups.tabline.bg },
    TabLineSel = { bg = groups.tabline.sel, bold = true },
    TabLineFill = { bg = groups.tabline.fill },

    CursorColumn = { bg = groups.bg.cursor_line },
    CursorLine = { bg = groups.bg.cursor_line },
    ColorColumn = { bg = groups.bg.color_column },
    QuickFixLine = { link = "Visual" },

    OkMsg = { fg = groups.diagnostic.ok.fg },

    Cursor = { bg = groups.bg.cursor },
    lCursor = { link = "Cursor" },

    FloatShadow = { bg = groups.bg.shadow, blend = 80 },
    FloatShadowThrough = { bg = groups.bg.shadow, blend = 100 },

    Substitute = { fg = groups.substitute.fg, bg = groups.substitute.bg },

    Special = { fg = groups.fg.special },

    LspCodeLens = { link = "LspInlayHint" },
    LspInlayHint = groups.inlay_hint,
    LspReferenceText = { bg = groups.bg.lsp_reference },

    DiagnosticError = { fg = groups.diagnostic.error.fg },
    DiagnosticWarn = { fg = groups.diagnostic.warn.fg },
    DiagnosticInfo = { fg = groups.diagnostic.info.fg },
    DiagnosticHint = { fg = groups.diagnostic.hint.fg },
    DiagnosticOk = { fg = groups.diagnostic.ok.fg },
    DiagnosticUnnecessary = { dim = true },

    DiagnosticVirtualTextError = groups.diagnostic.error,
    DiagnosticVirtualTextWarn = groups.diagnostic.warn,
    DiagnosticVirtualTextInfo = groups.diagnostic.info,
    DiagnosticVirtualTextHint = groups.diagnostic.hint,
    DiagnosticVirtualTextOk = groups.diagnostic.ok,

    DiagnosticUnderlineError = { special = groups.diagnostic.error.fg, undercurl = true },
    DiagnosticUnderlineWarn = { special = groups.diagnostic.warn.fg, undercurl = true },
    DiagnosticUnderlineInfo = { special = groups.diagnostic.info.fg, undercurl = true },
    DiagnosticUnderlineHint = { special = groups.diagnostic.hint.fg, undercurl = true },
    DiagnosticUnderlineOk = { special = groups.diagnostic.ok.fg, underline = true },

    Added = { fg = groups.diff.added.fg },
    Changed = { fg = groups.diff.changed.fg },
    Removed = { fg = groups.diff.removed.fg },

    DiffAdd = { bg = groups.diff.added.bg },
    DiffChange = {},
    DiffDelete = { bg = groups.diff.removed.bg },
    DiffText = { bg = groups.diff.changed.bg },
    DiffTextAdd = { bg = groups.diff.added.bg },

    ["@diff.plus"] = { link = "DiffAdd" },
    ["@diff.delta"] = { link = "DiffChange" },
    ["@diff.minus"] = { link = "DiffDelete" },

    MatchParen = groups.match_paren,

    Character = groups.symbols.character,
    Constant = groups.symbols.constant,
    Number = groups.symbols.number,
    Boolean = groups.symbols.boolean,
    Statement = { link = "Keyword" },
    Label = groups.symbols.label,
    Keyword = groups.symbols.keyword,
    ["@keyword.operator"] = groups.symbols.operator,
    PreProc = { link = "Keyword" },
    Macro = groups.symbols.macro,
    ["@constant.macro"] = bold(groups.symbols.macro),
    Type = groups.symbols.type,
    Tag = groups.symbols.tag,

    Comment = groups.symbols.comment,
    ["@variable"] = { italic = true },
    ["@variable.member"] = groups.symbols.member,
    ["@lsp.type.parameter"] = groups.symbols.parameter,

    ["@variable.builtin"] = { bold = true },
    ["@variable.parameter.builtin"] = bold(groups.symbols.parameter),
    ["@constant"] = groups.symbols.constant,
    ["@constant.builtin"] = bold(groups.symbols.constant),
    ["@module"] = groups.symbols.module,
    ["@module.builtin"] = bold(groups.symbols.module),

    String = groups.symbols.string,
    ["@string.escape"] = groups.symbols.escape,
    ["@string.regexp"] = groups.symbols.regex,
    ["@string.special.path"] = groups.symbols.path,

    ["@type.builtin"] = bold(groups.symbols.type),
    ["@attribute"] = groups.symbols.attribute,
    ["@attribute.builtin"] = bold(groups.symbols.attribute),
    ["@tag.attribute"] = groups.symbols.attribute,
    ["@property"] = groups.symbols.member,
    Identifier = { link = "@variable" },
    Function = groups.symbols["function"],
    ["@function.builtin"] = bold(groups.symbols["function"]),
    ["@function.macro"] = groups.symbols.macro,
    ["@constructor"] = groups.symbols.constructor,
    Operator = groups.symbols.operator,
    Delimiter = groups.symbols.delimiter,
    ["@tag.delimiter"] = groups.symbols.delimiter,
    ["@punctuation.special"] = groups.symbols.operator,
    TODO = groups.todo,

    ["@tag.builtin"] = bold(groups.symbols.tag),

    ["@lsp.type.concept"] = groups.symbols.concept,
    ["@lsp.type.lifetime"] = groups.symbols.lifetime,
    ["@lsp.type.component"] = groups.symbols.component,
    ["@lsp.type.escapeSequence"] = groups.symbols.escape,
    ["@lsp.typemod.variable.mutable"] = { underline = true },
    ["@lsp.type.selfKeyword"] = groups.symbols.self,
    ["@lsp.type.selfTypeKeyword"] = { bold = true },
    ["@lsp.typemod.selfKeyword"] = groups.symbols.self_type,
    ["@lsp.type.builtinAttribute"] = { bold = true },

    ["@markup.quote"] = { fg = groups.fg.normal },
    ["@markup.link"] = {},
    ["@markup.link.label"] = { fg = groups.symbols.label.fg },
    ["@markup.link.url"] = { underline = true },
    ["@markup.raw"] = { fg = groups.markup.raw },
    ["@markup.list"] = { fg = groups.markup.list },
    ["@markup.list.checked"] = { fg = groups.markup.checked },
    ["@markup.list.unchecked"] = { fg = groups.markup.unchecked },

    -- mini-icons
    MiniIconsAzure = { fg = groups.colors.azure },
    MiniIconsBlue = { fg = groups.colors.blue },
    MiniIconsCyan = { fg = groups.colors.cyan },
    MiniIconsGreen = { fg = groups.colors.green },
    MiniIconsGrey = { fg = groups.colors.grey },
    MiniIconsRed = { fg = groups.colors.red },
    MiniIconsOrange = { fg = groups.colors.orage },
    MiniIconsPurple = { fg = groups.colors.purple },
    MiniIconsYellow = { fg = groups.colors.yellow },

    -- blink
    BlinkCmpMenuBorder = { link = "PmenuBorder" },
    BlinkCmpLabelMatch = { link = "PmenuMatch" },
    BlinkCmpLabelDeprecated = { strikethrough = true },

    BlinkCmpKindText = groups.symbols.comment,
    BlinkCmpKindMethod = groups.symbols["function"],
    BlinkCmpKindFunction = groups.symbols["function"],
    BlinkCmpKindConstructor = groups.symbols.constructor,
    BlinkCmpKindField = groups.symbols.member,
    BlinkCmpKindVariable = groups.symbols.variable,
    BlinkCmpKindClass = groups.symbols.type,
    BlinkCmpKindInterface = groups.symbols.type,
    BlinkCmpKindModule = groups.symbols.module,
    BlinkCmpKindProperty = groups.symbols.member,
    BlinkCmpKindUnit = groups.symbols.operator,
    BlinkCmpKindValue = groups.symbols.boolean,
    BlinkCmpKindEnum = groups.symbols.constant,
    BlinkCmpKindKeyword = groups.symbols.keyword,
    BlinkCmpKindSnippet = groups.symbols.keyword,
    BlinkCmpKindColor = groups.symbols.constant,
    BlinkCmpKindFile = { fg = groups.fg.inactive },
    BlinkCmpKindReference = groups.symbols.member,
    BlinkCmpKindFolder = { fg = groups.fg.directory },
    BlinkCmpKindEnumMember = groups.symbols.member,
    BlinkCmpKindConstant = groups.symbols.constant,
    BlinkCmpKindStruct = groups.symbols.type,
    BlinkCmpKindEvent = groups.symbols.type,
    BlinkCmpKindOperator = groups.symbols.operator,
    BlinkCmpKindTypeParameter = groups.symbols.type,

    RenderMarkdownH1 = { fg = groups.fg.title },
    RenderMarkdownH2 = { fg = groups.fg.title },
    RenderMarkdownH3 = { fg = groups.fg.title },
    RenderMarkdownH4 = { fg = groups.fg.title },
    RenderMarkdownH5 = { fg = groups.fg.title },
    RenderMarkdownH6 = { fg = groups.fg.title },
    RenderMarkdownH1Bg = { bg = groups.bg.title },
    RenderMarkdownH2Bg = { bg = groups.bg.title },
    RenderMarkdownH3Bg = { bg = groups.bg.title },
    RenderMarkdownH4Bg = { bg = groups.bg.title },
    RenderMarkdownH5Bg = { bg = groups.bg.title },
    RenderMarkdownH6Bg = { bg = groups.bg.title },
    RenderMarkdownCode = { bg = groups.inlay_hint.bg },
    RenderMarkdownTableHead = { fg = groups.fg.border },
    RenderMarkdownTableRow = { fg = groups.fg.border },
    RenderMarkdownBullet = { link = "@markup.list" },

    DropBarIconKindDefault = { fg = groups.fg.mode_msg },
    DropBarIconKindMarkdownH1 = { fg = groups.fg.title },
    DropBarIconKindMarkdownH2 = { fg = groups.fg.title },
    DropBarIconKindMarkdownH3 = { fg = groups.fg.title },
    DropBarIconKindMarkdownH4 = { fg = groups.fg.title },
    DropBarIconKindMarkdownH5 = { fg = groups.fg.title },
    DropBarIconKindMarkdownH6 = { fg = groups.fg.title },
  }

  for name, val in pairs(values) do
    vim.api.nvim_set_hl(0, name, val)
  end

  for name, val in pairs(groups.custom) do
    vim.api.nvim_set_hl(0, name, val)
  end

  for idx, color in ipairs(groups.ansi) do
    if type(color) == "number" then
      color = ("#%X"):format(color)
    end
    vim.g["terminal_color_" .. idx - 1] = color
  end
end

return {
  set_hl = set_hl,
}
