---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/jackdewinter/pymarkdown",
    description = "A markdown linter and formatter.",
  },
  command = "pymarkdownlnt",
  args = { "--return-code-scheme", "minimal", "fix", "$FILENAME" },
  stdin = false,
}
