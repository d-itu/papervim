local storage = vim.fn.stdpath "state" .. "/session"
local projects = storage .. "/projects"

---@param path string
---@param content string
local function fs_write(path, content)
  local file = assert(io.open(path, "w"), "can't open file: " .. path)
  file:write(content)
  file:flush()
  file:close()
end

---@class manifest
---@field dir string
---@field expanded_nodes? string[]

---@param s string
---@return manifest?
local function manifest_decode(s)
  local ok, result = pcall(vim.json.decode, s)
  if not ok or not result.dir then return end
  return result
end

---@return string[]?
local function expanded_nodes()
  local ok, fyler_finder = pcall(require, "fyler.finder")
  if not ok then return end
  local instance = fyler_finder.instance_get()
  local result = {}
  for k, v in pairs(instance.state.meta) do
    if v then table.insert(result, k) end
  end
  return result
end

---@param dir string
local function get_session_dir(dir)
  local hash = vim.fn.sha256(dir)
  return vim.fs.joinpath(projects, hash)
end

---@param dir string
local function save_project(dir)
  local session_dir = get_session_dir(dir)
  vim.fn.mkdir(session_dir, "p")
  vim.cmd("mksession! " .. session_dir .. "/Session.vim")

  fs_write(session_dir .. "/manifest.json", vim.json.encode {
    dir = dir,
    expanded_nodes = expanded_nodes(),
  })
end

---@param manifest manifest
---@param session_dir string
local function load_project(session_dir, manifest)
  vim.cmd.source(session_dir .. "/Session.vim")

  if manifest.expanded_nodes then
    require "papervim.plugins.fyler"
    local instance = require "fyler.finder".instance_get()
    for _, node in ipairs(manifest.expanded_nodes) do
      instance.state.meta[node] = true
    end
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_option_value("buftype", { buf = buf }) ~= "" then goto continue end
    local name = vim.api.nvim_buf_get_name(buf)
    if vim.fn.filereadable(name) == 0 then
      vim.api.nvim_buf_delete(buf, {})
      goto continue
    end
    local ft = vim.filetype.match { buf = buf }
    if ft then
      vim.api.nvim_set_option_value("filetype", ft, { buf = buf })
    end
    ::continue::
  end
end

---@return string[]
local function list_projects()
  local dir = vim.uv.fs_opendir(projects)
  if not dir then return {} end
  local result = {}
  while true do
    local entries = vim.uv.fs_readdir(dir)
    if not entries then break end

    for _, entry in ipairs(entries) do
      local manifest = io.open(vim.fs.joinpath(projects, entry.name, "manifest.json"))
      if not manifest then goto continue end
      local decoded = manifest_decode(manifest:read "*a")
      manifest:close()
      if not decoded then goto continue end
      table.insert(result, decoded.dir)
      ::continue::
    end
  end
  dir:closedir()
  return result
end

---@param dir string
local function inspect(dir)
  vim.cmd.edit(get_session_dir(dir) .. "/Session.vim")
end

---@type table<string, fun(dir: string)>
local actions = {
  delete = function(dir)
    local session_dir = get_session_dir(dir)
    if vim.fn.isdirectory(session_dir) == 1 then
      vim.fs.rm(session_dir, { force = true, recursive = true })
      vim.api.nvim_echo({ { "deleted session: " .. dir } }, true, {})
    else
      vim.api.nvim_echo({ { "session not exists: " .. dir } }, true, { kind = "wmsg" })
    end
  end,
  load = function(dir)
    local session_dir = get_session_dir(dir)

    local manifest = io.open(session_dir .. "/manifest.json")
    if not manifest then
      vim.api.nvim_echo({ { "session not exists: " .. dir } }, true, { err = true })
      return
    end
    local manifest = manifest_decode(manifest:read "*a")
    if not manifest then
      vim.api.nvim_echo({ { "cannot decode manifest: " .. dir } }, true, { err = true })
      return
    end

    load_project(session_dir, manifest)
  end,
  inspect = inspect,
}

---@param action? string
local function select_project(action)
  local action = action or "inspect"
  local f = actions[action]
  local on_choice = f
      and function(dir) if dir then f(dir) end end
      or vim.print

  local ui = require "papervim.picker.ui"

  vim.ui.select(list_projects(), {
    prompt = action .. " session: ",
    format_item = require "papervim.utils".substitute_home,
    preview_item = function(dir)
      return {
        buf = ui.preview_file(get_session_dir(dir) .. "/Session.vim", "vim")
      }
    end
  }, on_choice)
end

vim.api.nvim_create_user_command("Project", function(args)
  local action = args.fargs[1]
  if #args.fargs < 2 then
    select_project(action)
    return
  end
  local proj = args.fargs[2]
  local cb = actions[action]
  if cb then
    cb(vim.fs.normalize(proj))
  end
end, {
  ---@param cmd_line string
  complete = function(_arg_lead, cmd_line, _cursor_pos)
    local args = vim.iter(cmd_line:gmatch "%S+"):totable()
    if #args == 1 then
      return vim.tbl_keys(actions)
    else
      return list_projects()
    end
  end,
  nargs = "*",
})

vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize"

if vim.fn.argc() == 1 then
  local path = vim.fn.argv()[1]
  if vim.fn.isdirectory(path) == 1 then
    vim.api.nvim_set_current_dir(path)
  else
    local dir = vim.fs.dirname(path)
    if vim.fn.isdirectory(dir) == 1 then
      vim.api.nvim_set_current_dir(dir)
    end
  end
end

local group = require "papervim.augroup"

---@param dir string
local function on_dir_changed(dir)
  if vim.v.this_session ~= "" then return end

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      local cwd = vim.fn.getcwd(-1, -1)
      if vim.fn.isdirectory(cwd .. "/.git") == 1 then
        save_project(cwd)
      end
    end,
    desc = "save project",
  })

  local session_dir = get_session_dir(dir)

  local manifest = io.open(session_dir .. "/manifest.json")
  if not manifest then return end
  local manifest = manifest_decode(manifest:read "*a")
  if not manifest then return end

  load_project(session_dir, manifest)
end

local path = vim.fn.expand "%"
if vim.fn.isdirectory(path) == 1 then
  vim.api.nvim_set_current_dir(path)
  on_dir_changed(path)
else
  local dir = vim.fs.dirname(path)
  if vim.fn.isdirectory(dir) == 1 then
    vim.api.nvim_set_current_dir(dir)
  end
end

vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "global",
  group = group,
  callback = function(arg)
    on_dir_changed(arg.file)
  end,
  desc = "load project",
})
