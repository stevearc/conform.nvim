---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/stylelint/stylelint",
    description = "A mighty CSS linter that helps you avoid errors and enforce conventions.",
  },
  command = "stylelint",
  args = { "--stdin", "--fix" },
  exit_codes = { 0, 2 }, -- code 2 is given when trying file includees some non-autofixable errors
  stdin = true,
}
