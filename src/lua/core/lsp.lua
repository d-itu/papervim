local f = require "core.format"

vim.cmd.packadd 'nvim-lspconfig'
vim.lsp.config("*", {
  reuse_client = function(client, conf)
    return client.name == conf.name
  end,
})
vim.lsp.config.qmlls = {
  cmd = { 'qmlls6' }
}
vim.lsp.config.lua_ls = {
  settings = {
    Lua = {
      completion = {
        postfix = ".",
      },
      diagnostics = {
        disable = { "redefined-local" },
        unusedLocalExclude = { "_*" },
      },
      hint = {
        setType = true,
      },
      runtime = {
        pathStrict = true,
      },
      type = {
        checkTableShape = true,
        inferParamName = true,
      },
    }
  }
}
vim.lsp.config.clangd = {
  cmd = {
    "clangd",
    "--clang-tidy",
    "--experimental-modules-support",
    -- "--compile-commands-dir=build",
  },
}
vim.lsp.config.jsonls = {
  settings = {
    json = {
      schemas = {
        {
          fileMatch = { "package.json" },
          url = "https://json.schemastore.org/package.json",
        },
        {
          fileMatch = { "tsconfig*.json" },
          url = "https://json.schemastore.org/tsconfig.json",
        },
      },
    },
  },
}
vim.lsp.config.rust_analyzer = {
  settings = {
    ['rust-analyzer'] = {
      check = {
        command = "clippy"
      },
      cargo = {
        features = "all",
      },
    },
  },
}
vim.lsp.config.ts_ls = {
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = '/usr/lib/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin',
        languages = { 'typescript', 'javascript', 'vue' },
      },
    },
  },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'vue',
  },
}

local hl_map = require 'core.diagnostic_hl'

vim.lsp.enable {
  "lua_ls",
  "bashls",
  "rust_analyzer",
  "clangd",
  "ts_ls",
  "zls",
  "hls",
  "wgsl_analyzer",
  "lemminx",
  "tombi",
  "mesonlsp",
  "vue_ls",
  "fish_lsp",
  "svelte",
  "qmlls",
  "jdtls",
  "cssls",
  "jsonls",
  "ocamllsp",
  "yamlls",
  "gopls",
  "ruff",
  "ty",
  "kotlin_lsp",
  "hyprls",
  "buf_ls",
  "html",
  "neocmake",
  'kdl_lsp',
}

---@param count table<integer, integer>
---@return integer?
local function max_severity(count)
  for severity = 1, 4 do
    if count[severity] and count[severity] ~= 0 then
      return severity
    end
  end
end

local group = require "core.augroup"

vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(args)
    ---@param count integer
    local function jump(count)
      vim.diagnostic.jump {
        severity = max_severity(vim.diagnostic.count(0)),
        count = count,
      }
    end

    vim.keymap.set('n', ']d', function() jump(1) end, { desc = "Next Diagnostic" })
    vim.keymap.set('n', '[d', function() jump(-1) end, { desc = "Previous Diagnostic" })
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = "Show diagnostics under the cursor" })

    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, { desc = "Rename" })
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, { desc = "Code Action" })
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, { desc = "Range Format" })
    vim.keymap.set('x', '<space>f', "gq", { desc = "Range Format" })

    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    if client:supports_method('textDocument/foldingRange') then
      vim.o.foldmethod = "expr"
      vim.wo.foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end

    if client:supports_method('textDocument/documentHighlight') then
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = vim.api.nvim_create_augroup("doc_hl" .. args.buf, { clear = true }),
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
        desc = "set document highlight",
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = vim.api.nvim_create_augroup("doc_hl_clear" .. args.buf, { clear = true }),
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
        desc = "unset document highlight",
      })
    end
    -- if client:supports_method("textDocument/completion") then
    --   local symbols = require "core.symbols"
    --   vim.list_extend(client.server_capabilities.completionProvider.triggerCharacters,
    --     vim.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", "")
    --   );
    --   vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
    --   vim.lsp.completion.enable(true, client.id, args.buf, {
    --     autotrigger = true,
    --     convert = function(item)
    --       return {
    --         kind = symbols.cmp.from_idx[item.kind]
    --       }
    --     end,
    --   })
    --   vim.keymap.set('i', '<C-Space>', vim.lsp.completion.get, {
    --     desc = "Completion"
    --   })
    -- end
  end
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function()
    vim.lsp.log.set_level 'OFF'
    vim.lsp.inlay_hint.enable(true)
    vim.lsp.inline_completion.enable(true);

    local diagnostic_signs = require "core.diagnostic_signs"
    vim.diagnostic.config {
      signs = {
        text = { '', '', '', '' },
      },
      virtual_text = {
        prefix = '',
      },
      severity_sort = true,
      status = {
        format = function(counts)
          if #vim.lsp.get_clients { bufnr = 0 } == 0 then return "" end
          if #counts < 2 then
            if counts[1] == nil then counts[1] = 0 end
            if counts[2] == nil then counts[2] = 0 end
          end
          return vim
              .iter(pairs(counts))
              :map(function(severity, count)
                return f(' %#{}#{} {}',
                  count ~= 0 and hl_map[severity] or "StatusLine",
                  diagnostic_signs[severity],
                  count
                )
              end)
              :join('')
        end,
      },
    }
  end,
  once = true,
})
