local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/jolars/panache",
    description = "Linter for Markdown, Quarto, and R Markdown. Applies auto-fixable rule violations.",
  },
  command = "panache",
  args = { "--stdin-filename", "$FILENAME", "lint", "--fix" },
  stdin = true,
  cwd = util.root_file({
    ".panache.toml",
    "panache.toml",
  }),
}
