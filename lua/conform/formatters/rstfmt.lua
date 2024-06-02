---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/dzhu/rstfmt",
    description = "A formatter for reStructuredText.",
  },
  command = "rstfmt",
  args = { "$FILENAME" },
  stdin = false,
}
