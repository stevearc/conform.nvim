---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/biomejs/biome",
    description = "A toolchain for web projects, aimed to provide functionalities to maintain them.",
  },
  command = "biome",

  -- pending this bug, do not use stdin: https://github.com/biomejs/biome/issues/455
  stdin = false,
  args = { "format", "--write", "$FILENAME" },
  -- stdin = true,
  -- args = { "format", "--stdin-file-path", "$FILENAME" },
}
