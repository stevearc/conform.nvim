local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/akaihola/darker",
    description = "Run black only on changed lines.",
  },
  command = "darker",
  args = {
    "--quiet",
    "--no-color",
    "--stdout",
    "--revision",
    "HEAD..:STDIN:",
    "--stdin-filename",
    "$FILENAME",
  },
  cwd = util.root_file({
    -- https://github.com/akaihola/darker#customizing-darker-black-isort-flynt-and-linter-behavior
    "pyproject.toml",
  }),
}
