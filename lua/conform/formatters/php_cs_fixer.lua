local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/PHP-CS-Fixer/PHP-CS-Fixer",
    description = "The PHP Coding Standards Fixer.",
  },
  command = util.find_executable({
    "tools/php-cs-fixer/vendor/bin/php-cs-fixer",
    "vendor/bin/php-cs-fixer",
  }, "php-cs-fixer"),
  args = { "fix", "$FILENAME" },
  stdin = false,
  cwd = util.root_file({ "composer.json" }),
}
