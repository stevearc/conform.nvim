local fs = require("conform.fs")
local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/beautifier/js-beautify",
    description = "Beautifier for javascript.",
  },
  command = util.from_node_modules(fs.is_windows and "js-beautify.cmd" or "js-beautify"),
  args = { "--editorconfig", "--file", "-" },
  cwd = util.root_file({
    -- https://github.com/beautifier/js-beautify#loading-settings-from-environment-or-jsbeautifyrc-javascript-only
    ".jsbeautifyrc",
  }),
}
