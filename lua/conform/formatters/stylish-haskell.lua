---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://hackage.haskell.org/package/stylish-haskell",
    description = "A simple Haskell code prettifier",
  },
  command = "stylish-haskell",
  args = { "$FILENAME" },
}
