local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/eslint/eslint",
    description = "A tool for identifying and reporting on patterns found in ECMAScript/JavaScript code",
  },
  command = util.from_node_modules("eslint"),
  args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
  cwd = util.root_file({
    "package.json",
  }),
}
