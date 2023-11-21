local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/sqlfluff/sqlfluff",
    description = "A modular SQL linter and auto-formatter with support for multiple dialects and templated code.",
  },
  command = "sqlfluff",
  args = { "fix", "--force", "--dialect=ansi", "-" },
  stdin = true,
  cwd = util.root_file({
    ".sqlfluff",
    "pep8.ini",
    "pyproject.toml",
    "setup.cfg",
    "tox.ini",
  }),
  require_cwd = false,
}
