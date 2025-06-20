local fs = require("conform.fs")
local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/beautifier/js-beautify",
    description = "Beautifier for css.",
  },
  command = util.from_node_modules(fs.is_windows and "css-beautify.cmd" or "css-beautify"),
  args = { "--editorconfig", "--file", "-" },
  cwd = util.root_file({
    -- https://github.com/beautifier/js-beautify#loading-settings-from-environment-or-jsbeautifyrc-javascript-only
    ".jsbeautifyrc",
  }),
}
