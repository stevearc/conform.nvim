---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/omnilib/ufmt",
    description = "Safe, atomic formatting with black and µsort.",
  },
  command = "ufmt",
  args = { "format", "$FILENAME" },
  stdin = false,
}
