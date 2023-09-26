local util = require("conform.util")
return {
  meta = {
    url = "https://github.com/PHP-CS-Fixer/PHP-CS-Fixer",
    description = "The PHP Coding Standards Fixer.",
  },
  command = util.path_or({
    "tools/php-cs-fixer/vendor/bin/php-cs-fixer",
    "vendor/bin/php-cs-fixer",
  }, "php-cs-fixer"),
  args = { "fix", "$FILENAME" },
  stdin = false,
}
