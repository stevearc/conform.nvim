local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/devOpifex/r.nvim",
    description = "R formatter and linter.",
  },
  command = util.find_executable({"usr/bin/"}, "R"),
  args = {"-s", "--vanilla", "-e", "r.nvim::format()", "--args", "$FILENAME", "grk"},
}
