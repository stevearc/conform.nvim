local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/stylelint/stylelint",
    description = "A mighty CSS linter that helps you avoid errors and enforce conventions.",
  },
  command = util.from_node_modules("stylelint"),
  args = { "--stdin", "--stdin-filename", "$FILENAME", "--fix" },
  exit_codes = { 0, 2 }, -- code 2 is given when trying file includees some non-autofixable errors
  stdin = true,
  cwd = util.root_file({
    "package.json",
  }),
}
