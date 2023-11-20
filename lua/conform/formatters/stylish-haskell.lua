---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://hackage.haskell.org/package/fourmolu",
    description = "A simple Haskell code prettifier",
  },
  command = "stylish-haskell",
  args = { "$FILENAME" },
}
