local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/dprint/dprint",
    description = "Pluggable and configurable code formatting platform written in Rust.",
  },
  command = util.from_node_modules("dprint"),
  args = { "fmt", "--stdin", "$FILENAME" },
  cwd = util.root_file({
    "dprint.json",
    ".dprint.json",
    "dprint.jsonc",
    ".dprint.jsonc",
  }),
}
