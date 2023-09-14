---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/DavidAnson/markdownlint",
    description = "A Node.js style checker and lint tool for Markdown/CommonMark files.",
  },
  command = "markdownlint",
  args = { "--fix", "$FILENAME" },
  stdin = false,
}
