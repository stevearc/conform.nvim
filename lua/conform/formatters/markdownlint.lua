---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/DavidAnson/markdownlint",
    description = "A Node.js style checker and lint tool for Markdown/CommonMark files.",
  },
  command = "markdownlint",
  args = { "--fix", "$FILENAME" },
  exit_codes = { 0, 1 }, -- code 1 is given when trying a file that includes non-autofixable errors
  stdin = false,
}
