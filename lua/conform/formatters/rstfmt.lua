---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/LilSpazJoekp/docstrfmt",
    description = "A formatter for reStructuredText.",
  },
  command = "rstfmt",
  args = { "$FILENAME" },
  stdin = false,
}
