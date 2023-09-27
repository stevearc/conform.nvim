local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/akaihola/darker",
    description = "Run black only on changed lines.",
  },
  command = "darker",
  args = { "--stdout", "--quiet", "$FILENAME" },
  cwd = util.root_file({
    -- https://github.com/akaihola/darker#customizing-darker-black-isort-flynt-and-linter-behavior
    "pyproject.toml",
  }),
}
