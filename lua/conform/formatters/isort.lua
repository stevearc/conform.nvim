local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/PyCQA/isort",
    description = "Python utility / library to sort imports alphabetically and automatically separate them into sections and by type.",
  },
  command = "isort",
  args = {
    "--stdout",
    "--filename",
    "$FILENAME",
    "-",
  },
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
