local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/microsoft/typespec",
    description = "TypeSpec compiler and CLI.",
  },
  command = util.from_node_modules("tsp"),
  stdin = false,
  args = { "format", "$FILENAME" },
  cwd = util.root_file({ "tspconfig.yaml" }),
}
