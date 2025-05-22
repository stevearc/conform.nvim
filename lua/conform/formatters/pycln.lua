local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/hadialqattan/pycln",
    description = "A Python formatter for finding and removing unused import statements.",
  },
  command = "pycln",
  args = {
    "--silence",
    "-",
  },
  cwd = util.root_file({
    "pyproject.toml",
    "setup.cfg",
  }),
}
