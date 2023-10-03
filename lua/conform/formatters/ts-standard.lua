local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://www.npmjs.com/package/ts-standard",
    description = "TypeScript Style Guide, with linter and automatic code fixer based on StandardJS",
  },
  command = util.from_node_modules("ts-standard"),
  args = { "--fix", "--stdin", "$FILENAME" },
}

