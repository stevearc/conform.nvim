local util = require("conform.util")
---@type conform.FormatterConfig
return {
  meta = {
    url = "https://github.com/JohnnyMorganz/StyLua",
    description = "An opinionated code formatter for Lua.",
  },
  command = "stylua",
  args = { "--search-parent-directories", "--stdin-filepath", "$FILENAME", "-" },
  cwd = util.root_file({
    ".stylua.toml",
    "stylua.toml",
  }),
}
