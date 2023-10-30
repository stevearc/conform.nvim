local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/facebook/usort",
    description = "Safe, minimal import sorting for Python projects.",
  },
  command = "usort",
  args = { "format", "-" },
  stdin = true,
  cwd = util.root_file({
    "pyproject.toml",
  }),
}
