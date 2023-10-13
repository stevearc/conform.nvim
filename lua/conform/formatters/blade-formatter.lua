local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/shufo/blade-formatter",
    description = "An opinionated blade template formatter for Laravel that respects readability.",
  },
  command = "blade-formatter",
  args = { "--stdin" },
  stdin = true,
  cwd = util.root_file({ "composer.json", "composer.lock" }),
}
