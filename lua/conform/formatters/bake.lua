---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/EbodShojaei/bake",
    description = "A Makefile formatter and linter. It only took 50 years!",
  },
  command = "bake",
  args = { "format", "$FILENAME" },
  stdin = false,
}
