---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/rokucommunity/brighterscript-formatter",
    description = "A code formatter for BrighterScript (and BrightScript).",
  },
  command = "bsfmt",
  args = { "$FILENAME", "--write" },
  stdin = false,
}
