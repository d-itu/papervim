-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionItemKind

local cmp_kind = {
  Text = "󰉿",
  Method = "",
  Function = "󰣪",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "",
  Interface = "",
  Module = "",
  Property = "󰖷",
  Unit = "",
  Value = "󰫧",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "󰈔",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = "",
}

return {
  map = cmp_kind,
  ---@type table<lsp.CompletionItemKind, string>
  from_completion_item_kind = vim.iter(cmp_kind):totable(),
}
