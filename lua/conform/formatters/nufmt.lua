---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/nushell/nufmt",
    description = "The nushell formatter.",
  },
  command = "nufmt",
  args = { "$FILENAME" },
  stdin = false,
}
