local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/oxc-project/oxc",
    description = "Oxlint (/oh-eks-lint/) is designed to catch erroneous or useless code without requiring any configurations by default.",
  },
  command = util.from_node_modules("oxfmt"),
  args = { "--fix", "$FILENAME" },
  stdin = false,
}
