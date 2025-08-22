---@type conform.FileFormatterConfig

return {
  meta = {
    url = "https://github.com/tombi-toml/tombi",
    description = "TOML Formatter / Linter.",
  },
  command = "tombi",
  args = { "format", "-" },
  stdin = true,
}
