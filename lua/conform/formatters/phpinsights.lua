local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/nunomaduro/phpinsights",
    description = "The perfect starting point to analyze the code quality of your PHP projects.",
  },
  command = util.find_executable({
    "vendor/bin/phpinsights",
  }, "phpinsights"),
  args = { "fix", "$FILENAME", "--no-interaction", "--quiet" },
  cwd = util.root_file({
    "phpinsights.php",
  }),
  stdin = false,
}
