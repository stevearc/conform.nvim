local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/laravel/pint",
    description = "Laravel Pint is an opinionated PHP code style fixer for minimalists. Pint is built on top of PHP-CS-Fixer and makes it simple to ensure that your code style stays clean and consistent.",
  },
  command = util.find_executable({
    vim.fn.stdpath("data") .. "/mason/bin/pint",
    "vendor/bin/pint",
  }, "pint"),
  args = { "$FILENAME" },
  stdin = false,
}
