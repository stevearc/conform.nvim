local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/lkrms/pretty-php",
    description = "The opinionated PHP code formatter.",
  },
  command = util.find_executable({
    "vendor/bin/pretty-php",
  }, "pretty-php"),
  args = { "$FILENAME" },
  stdin = false,
}
