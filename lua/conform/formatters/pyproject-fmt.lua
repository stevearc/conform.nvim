local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/tox-dev/toml-fmt/tree/main/pyproject-fmt",
    description = "Apply a consistent format to your pyproject.toml file with comment support.",
  },
  command = "pyproject-fmt",
  args = {
    "-",
  },
  cwd = util.root_file({
    "pyproject.toml",
  }),
  exit_codes = { 0, 1 }, -- 1 error code used when formatting is successful and if there are errors
}
