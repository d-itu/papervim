vim.cmd.packadd "rose-pine"
local palette = require "rose-pine.palette"
local config = require "rose-pine.config"
local groups = config.options.groups
require "rose-pine".setup {
  enable = {
    migrations = false,
  },
  highlight_groups = {
    OkMsg              = { fg = palette.leaf },

    FylerDirectoryName = { link = "Directory" },
    FylerGitConflict   = { fg = groups.git_merge },
    FylerGitDeleted    = { fg = groups.git_delete },
    FylerGitIgnored    = { fg = groups.git_ignore },
    FylerGitModified   = { fg = groups.git_dirty },
    FylerGitRenamed    = { fg = groups.git_rename },
    FylerGitStaged     = { fg = groups.git_stage },
    FylerGitUntracked  = { fg = groups.git_untracked },
  },
}
