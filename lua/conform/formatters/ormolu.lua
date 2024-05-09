---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://hackage.haskell.org/package/ormolu",
    description = "Ormolu is a formatter for Haskell source code.",
  },
  command = "ormolu",
  args = { "--stdin-input-file", "$FILENAME" },
  stdin = true,
}
