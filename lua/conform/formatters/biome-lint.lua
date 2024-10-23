local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/biomejs/biome",
    description = "A toolchain for web projects, aimed to provide functionalities to maintain them.",
  },
  command = util.from_node_modules("biome"),
  stdin = true,
  args = { "lint", "--write", "--unsafe", "--stdin-file-path", "$FILENAME" },
  cwd = util.root_file({
    "biome.json",
    "biome.jsonc",
  }),
}
