local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/oxc-project/oxc",
    description = "Oxfmt (/oh-eks-for-mat/) is a Prettier-compatible code formatter.",
  },
  command = util.from_node_modules("oxfmt"),
  args = { "$FILENAME" },
  stdin = false,
}
