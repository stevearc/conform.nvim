local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/psf/black",
    description = "The uncompromising Python code formatter.",
  },
  command = "black",
  args = {
    "--stdin-filename",
    "$FILENAME",
    "--quiet",
    "-",
  },
  cwd = util.root_file({
    -- https://black.readthedocs.io/en/stable/usage_and_configuration/the_basics.html#configuration-via-a-file
    "pyproject.toml",
  }),
}
