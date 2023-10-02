local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/squizlabs/PHP_CodeSniffer",
    description = "PHP Code Beautifier and Fixer",
  },
  command = util.find_executable({
    "tools/phpcbf",
    "vendor/bin/phpcbf",
    "PHP_CodeSniffer/bin/phpcbf",
  }, "phpcbf"),
  args = { "-q", "$FILENAME" },
  stdin = false,
}
