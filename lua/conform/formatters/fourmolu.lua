---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://hackage.haskell.org/package/fourmolu",
    description = "Fourmolu is a formatter for Haskell source code.",
  },
  command = "fourmolu",
  args = { "--stdin-input-file", "$FILENAME" },
  stdin = true,
}
