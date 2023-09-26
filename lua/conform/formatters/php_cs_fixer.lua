local util = require("conform.util")
return {
  command = util.path_or({
    "tools/php-cs-fixer/vendor/bin/php-cs-fixer",
    "vendor/bin/php-cs-fixer",
  }, "php-cs-fixer"),
  args = { "fix", "$FILENAME" },
  stdin = false,
}
