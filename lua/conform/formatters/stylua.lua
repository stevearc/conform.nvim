---@type conform.FormatterConfig
return {
  meta = {
    url = "https://github.com/JohnnyMorganz/StyLua",
    description = "An opinionated code formatter for Lua.",
  },
  command = "stylua",
  args = { "--search-parent-directories", "--stdin-filepath", "$FILENAME", "-" },
}
