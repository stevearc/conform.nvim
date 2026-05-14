local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://pg-language-server.com/latest/features/formatting",
    description = "The language server provides SQL formatting that produces consistent, readable code. Built on Postgres' own parser, the formatter ensures 100% syntax compatibility with your SQL.",
  },
  stdin = false,
  command = "postgres-language-server",
  args = { "format", "--write", "$FILENAME" },
  cwd = util.root_file({ "postgres-language-server.jsonc" }),
}
