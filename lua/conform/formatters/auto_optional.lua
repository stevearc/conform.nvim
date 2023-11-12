---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://auto-optional.daanluttik.nl/",
    description = "Adds the Optional type-hint to arguments where the default value is None.",
  },
  command = "auto-optional",
  args = {
    "$FILENAME",
  },
  stdin = false,
}
