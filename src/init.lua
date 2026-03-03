require "core.options"
require "core.keymaps"

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.hl.on_yank() end,
  desc = 'yank',
})

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
vim.cmd.packadd 'nvim-lspconfig'
vim.lsp.enable {
  "lua_ls",
  "bashls",
  "rust_analyzer",
  "clangd",
}
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    ---@param dir integer
    local function jump(dir)
      local count = vim.diagnostic.count(0)
      local max = 4
      for index, value in ipairs(count) do
        if value ~= 0 then
          max = index
          break
        end
      end
      vim.diagnostic.jump {
        severity = max,
        count = dir,
      }
    end

    vim.keymap.set('n', ']d', function() jump(1) end, { desc = "Jump to the next diagnostic in the current buffer" })
    vim.keymap.set('n', '[d', function() jump(-1) end, { desc = "Jump to the previous diagnostic in the current buffer" })
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = "Show diagnostics under the cursor" })

    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method("textDocument/completion") then
      vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
      vim.keymap.set('i', '<C-Space>', vim.lsp.completion.get, {
        desc = "Completion"
      })
    end
  end
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    local diagnostic_icons = { "", "", "", "" }
    vim.diagnostic.config {
      signs = {
        text = diagnostic_icons,
      },
      virtual_text = {},
      severity_sort = true,
      status = {
        text = diagnostic_icons,
      },
    }
  end,
  once = true,
})
