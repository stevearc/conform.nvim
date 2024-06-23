---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://grain-lang.org",
    description = "Code formatting for the grain programming language.",
  },
  command = "grain",
  args = { "format", "$FILENAME", "-o", "$FILENAME" },
  stdin = false,
}
