---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/mihaimaruseac/hindent",
    description = "Haskell pretty printer.",
  },
  command = "hindent",
  args = { "$FILENAME" },
  stdin = false,
}
