local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://docs.trunk.io/code-quality/overview/getting-started/commands-reference/code-quality#trunk-check-run-format",
    description = "Trunk universal formatter.",
  },
  command = util.from_node_modules("trunk"),
  args = { "fmt", "$FILENAME" },
  stdin = false,
}
