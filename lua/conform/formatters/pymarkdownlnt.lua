---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/jackdewinter/pymarkdown",
    description = "PyMarkdown is primarily a Markdown linter",
  },
  command = "pymarkdownlnt",
  args = { "--return-code-scheme", "minimal", "fix", "$FILENAME" },
  stdin = false,
}
