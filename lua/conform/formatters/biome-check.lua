local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://biomejs.dev/reference/cli/#biome-check",
    description = "A toolchain for web projects, aimed to provide functionalities to maintain them. This config runs formatting, linting and import sorting. See `biome` or `biome-organize-imports` for other options.",
  },
  command = util.from_node_modules("biome"),
  stdin = true,
  args = { "check", "--write", "--stdin-file-path", "$FILENAME" },
  cwd = util.root_file({
    "biome.json",
    "biome.jsonc",
  }),
}
