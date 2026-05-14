local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/jolars/panache",
    description = "A formatter, linter, and language server for Markdown, Quarto, and R Markdown.",
  },
  command = "panache",
  args = { "--stdin-filename", "$FILENAME", "format" },
  stdin = true,
  cwd = util.root_file({
    ".panache.toml",
    "panache.toml",
  }),
}
