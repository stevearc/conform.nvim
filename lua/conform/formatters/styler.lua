local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/devOpifex/r.nvim",
    description = "R formatter and linter.",
  },
  command = util.find_executable({ "usr/bin/" }, "R"),
  -- Any args to style_file must be passed after `commandArgs(TRUE)`
  -- Include "--no-init-file" before "e" to ignore .Rprofile, for example
  -- to avoid long renv startup time
  args = { "-s", "-e", "styler::style_file(commandArgs(TRUE))", "--args", "$FILENAME" },
  stdin = false,
}
