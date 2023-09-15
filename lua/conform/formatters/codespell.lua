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
  exit_codes = { 0, 65 }, -- code 65 is given when trying to format an ambiguous misspelling
}
