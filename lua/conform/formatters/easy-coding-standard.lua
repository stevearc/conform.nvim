local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/easy-coding-standard/easy-coding-standard",
    description = "ecs - Use Coding Standard with 0-knowledge of PHP-CS-Fixer and PHP_CodeSniffer.",
  },
  command = util.find_executable({
    "vendor/bin/ecs",
  }, "ecs"),
  args = { "check", "$FILENAME", "--fix", "--no-interaction" },
  cwd = util.root_file({
    "ecs.php",
  }),
  require_cwd = true,
  stdin = false,
}
