local fs = require("conform.fs")
local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/beautifier/js-beautify",
    description = [[This little beautifier will reformat and re-indent bookmarklets, ugly JavaScript, unpack scripts packed by Dean Edward’s popular packer, as well as partly deobfuscate scripts processed by the npm package javascript-obfuscator.]],
  },
  command = util.from_node_modules(fs.is_windows and "css-beautify.cmd" or "css-beautify"),
  args = { "--file", "-" },
  cwd = util.root_file({
    -- https://github.com/beautifier/js-beautify#loading-settings-from-environment-or-jsbeautifyrc-javascript-only
    ".jsbeautifyrc",
  }),
}
