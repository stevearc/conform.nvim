---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://hackage.haskell.org/package/hindent",
    description = "Extensible Haskell pretty printer.",
  },
  command = "hindent",
  args = { "$FILENAME" },
}
