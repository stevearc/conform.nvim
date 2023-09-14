---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/stylelint/stylelint",
    description = "A mighty CSS linter that helps you avoid errors and enforce conventions.",
  },
  command = "stylelint",
  args = { "--stdin", "--fix" },
  stdin = true,
}
