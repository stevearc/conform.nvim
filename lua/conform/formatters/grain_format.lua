---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://grain-lang.org/docs/tooling/grain_cli#grain-format",
    description = "Code formatter for the grain programming language.",
  },
  command = "grain",
  args = { "format", "$FILENAME" },
  stdin = true,
}
