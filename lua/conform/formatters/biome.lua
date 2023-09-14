---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/biomejs/biome",
    description = "A toolchain for web projects, aimed to provide functionalities to maintain them.",
  },
  command = "biome",
  stdin = true,
  args = { "format", "--stdin-file-path", "$FILENAME" },
}
