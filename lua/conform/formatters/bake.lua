---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/EbodShojaei/bake",
    description = "A Makefile formatter and linter.",
  },
  command = "mbake",
  args = { "format", "$FILENAME" },
  stdin = false,
}
