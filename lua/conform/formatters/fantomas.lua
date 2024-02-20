---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/fsprojects/fantomas",
    description = "F# source code formatter.",
  },
  command = "fantomas",
  args = { "$FILENAME" },
  stdin = false,
}
