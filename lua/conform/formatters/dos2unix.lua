local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://dos2unix.sourceforge.io/",
    description = "Convert from dos line endings to unix line endings",
  },
  command = "dos2unix",
  args = {
    "--to-stdout",
  },
}
