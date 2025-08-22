local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/PyCQA/isort",
    description = "Python utility / library to sort imports alphabetically and automatically separate them into sections and by type.",
  },
  command = "isort",
  args = function(self, ctx)
    return {
      "--stdout",
      "--line-ending",
      util.buf_line_ending(ctx.buf),
      "--filename",
      "$FILENAME",
      "-",
    }
  end,
  cwd = util.root_file({
    -- https://pycqa.github.io/isort/docs/configuration/config_files.html
    ".isort.cfg",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "tox.ini",
    ".editorconfig",
  }),
}
