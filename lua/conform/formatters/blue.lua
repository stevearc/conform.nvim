local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/grantjenks/blue",
    description = "The slightly less uncompromising Python code formatter.",
  },
  command = "blue",
  args = {
    "--stdin-filename",
    "$FILENAME",
    "--quiet",
    "-",
  },
  cwd = util.root_file({
    "setup.cfg",
    "pyproject.toml",
    "tox.ini",
    ".blue",
  }),
}
