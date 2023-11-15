---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/DavidAnson/markdownlint-cli2",
    description = "A fast, flexible, configuration-based command-line interface for linting Markdown/CommonMark files with the markdownlint library.",
  },
  command = "markdownlint-cli2",
  args = { "--fix", "$FILENAME" },
  exit_codes = { 0, 1 }, -- code 1 is returned when linting/formatter was successful and there were errors
  stdin = false,
}
