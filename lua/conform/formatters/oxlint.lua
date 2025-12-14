local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/oxc-project/oxc",
    description = "An oxidized replacement for ESLint that fixes lint errors.",
  },
  command = util.from_node_modules("oxlint"),
  args = { "--fix", "$FILENAME" },
  stdin = false,
}
