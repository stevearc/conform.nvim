local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/grantjenks/blue",
    description = "Blue -- Some folks like black but I prefer blue.",
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
