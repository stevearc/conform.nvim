---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/LilSpazJoekp/docstrfmt",
    description = "reStructuredText formatter.",
  },
  command = "docstrfmt",
  args = { "-" },
  stdin = true,
}
