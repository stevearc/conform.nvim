---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/codespell-project/codespell",
    description = "Check code for common misspellings.",
  },
  command = "codespell",
  stdin = false,
  args = {
    "$FILENAME",
    "--write-changes",
    "--check-hidden", -- conform's temp file is hidden
  },
}
