---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/scalameta/scalafmt",
    description = "Code formatter for Scala.",
  },
  command = "scalafmt",
  args = { "--stdin" },
}
