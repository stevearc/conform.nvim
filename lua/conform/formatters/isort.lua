local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/PyCQA/isort",
    description = "Python utility / library to sort imports alphabetically and automatically separate them into sections and by type.",
  },
  command = "isort",
  args = function(self, ctx)
    -- isort doesn't do a good job of auto-detecting the line endings.
    local line_ending
    local file_format = vim.bo[ctx.buf].fileformat
    if file_format == "dos" then
      line_ending = "\r\n"
    elseif file_format == "mac" then
      line_ending = "\r"
    else
      line_ending = "\n"
    end
    return {
      "--stdout",
      "--line-ending",
      line_ending,
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
