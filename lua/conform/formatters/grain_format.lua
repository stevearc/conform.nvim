---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://grain-lang.org",
    description = "Code formatter for the grain programming language.",
  },
  command = "grain",
  args = { "format", "$FILENAME", "-o", "$FILENAME" },
  stdin = false,
}
