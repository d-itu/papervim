---@type (vim.pack.Spec | string)[]
local specs = {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/d-itu/nvim-treesitter',

  -- cmp
  "https://github.com/saghen/blink.cmp",
  "https://github.com/milanglacier/minuet-ai.nvim",

  -- ui
  "https://github.com/j-hui/fidget.nvim",
  "https://github.com/FylerOrg/fyler.nvim",
  "https://github.com/Bekaboo/dropbar.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/petertriho/nvim-scrollbar",
  "https://github.com/d-itu/indentify",

  -- utils
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/kylechui/nvim-surround",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/meanderingprogrammer/render-markdown.nvim",
  "https://github.com/acidsugarx/babel.nvim",

  -- deps
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/saghen/blink.lib",
  "https://github.com/d-itu/lua-format",
  "https://github.com/folke/snacks.nvim", -- for fzf image preview

  -- colorschemes
  { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
  "https://github.com/folke/tokyonight.nvim",
}

local ffi = require "ffi"
ffi.cdef [[void *signal(int signum, void *handler);]]
local SIGINT = 2
local SIG_DFL = ffi.cast("void *", 0)
ffi.C.signal(SIGINT, SIG_DFL)

local data_dir = vim.fn.stdpath "data"

---@param name string
local function plugin_dir(name)
  return vim.fs.joinpath(data_dir, "site/pack/core/opt", name)
end

local function post_update()
  vim.cmd.chdir(plugin_dir("blink.cmp"))
  os.execute [[
test -e lib/libblink_cmp_fuzzy.so && exit 0
cargo build --profile=native
mkdir -p lib
cp target/native/libblink_cmp_fuzzy.so lib/libblink_cmp_fuzzy.so
]]

  vim.system({ "cargo", "build", "--release" }, { cwd = plugin_dir("lua-format") }):wait()
  vim.cmd.packadd 'nvim-treesitter'
  local languages = {
    'bash',
    'c',
    'caddy',
    'cmake',
    'cpp',
    'css',
    'desktop',
    'diff',
    'dtd',
    'git_config',
    'gitcommit',
    'glsl',
    'html',
    'hyprlang',
    'ini',
    'javascript',
    'json',
    'kdl',
    'kitty',
    'kotlin',
    'llvm',
    'lua',
    'make',
    'markdown',
    'markdown_inline',
    'meson',
    'nisba',
    'objdump',
    'odin',
    'proto',
    'python',
    'regex',
    'rust',
    'scss',
    'ssh_config',
    'toml',
    'typescript',
    'typst',
    'vim',
    'wgsl',
    'xml',
    'yaml',
    'yuck',
    'zig',
  }
  vim.api.nvim_create_autocmd("User", {
    pattern = "TSUpdate",
    callback = function()
      local parsers = require 'nvim-treesitter.parsers'
      parsers.wgsl = {
        install_info = {
          url = 'https://github.com/d-itu/tree-sitter-wgsl',
          revision = 'master',
          queries = 'nvim/queries/wgsl',
        },
        maintainers = { "@d-itu" },
        tier = 2,
      }
      parsers.nisba = {
        install_info = {
          url = 'https://github.com/d-itu/tree-sitter-nisba',
          revision = 'master',
          queries = 'nvim/queries/nisba',
          generate_from_json = false,
          generate = true,
        },
        maintainers = { "@d-itu" },
        tier = 2,
      }
    end,
  })
  require "nvim-treesitter".setup()
  require 'nvim-treesitter'.install(languages, { summary = true }):wait()
end

---@param spec vim.pack.Spec | string
---@return string
local function name(spec)
  if type(spec) == "string" then
    return vim.fs.basename(spec)
  end
  return spec.name
end

---@param path string
local function is_dir(path)
  return vim.fn.isdirectory(path) == 1
end

local function generate_luarc()
  local libraries = vim.iter(specs)
      :map(name)
      :map(plugin_dir)
      :map(function(path) return vim.fs.joinpath(path, "lua") end)
      :filter(is_dir)

  local luarc = vim.json.encode {
    ["$schema"] = "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json",
    runtime = {
      version = "LuaJIT",
      pathStrict = true,
    },
    ["workspace.library"] = {
      vim.fs.joinpath(vim.env.VIMRUNTIME, "lua/vim"),
      "${workspaceFolder}/src/lua",
      "${3rd}/luv/library",
      unpack(libraries:totable())
    },
    diagnostics = {
      unusedLocalExclude = { "_*" },
      disable = { "redefined-local" },
    },
  }

  local file, err = io.open(".luarc.json", "w")
  if file == nil then
    io.stderr:write(err, "\n")
    os.exit(1)
  end
  file:write(luarc)
end

local function sync()
  vim.pack.add(specs, { load = false })
  post_update()
end

local function update()
  vim.pack.add(specs, { load = false })
  vim.pack.update(vim.iter(specs):map(name):totable(), { force = true })
  post_update()
end

local function clean()
  local path = vim.fs.joinpath(vim.fn.stdpath "config", "nvim-pack-lock.json")
  ---@type vim.pack.Lock
  local lock = vim.json.decode(io.open(path):read "*a")
  local required = vim.iter(specs):map(name):fold({}, function(acc, x)
    acc[x] = true
    return acc
  end)
  for key, _ in pairs(lock.plugins) do
    if not required[key] then
      vim.pack.del { key }
      io.stderr:write "\n"
    end
  end
end

local commands = {
  generate_luarc = generate_luarc,
  sync = sync,
  update = update,
  post_update = post_update,
  clean = clean,
  help = function() vim.print("USAGE: " .. arg[0] .. " <CMD>") end,
}

if not arg[0] then return commands end

commands[arg[1] or "help"]()
