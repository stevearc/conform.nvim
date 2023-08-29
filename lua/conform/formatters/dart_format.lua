---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://dart.dev/tools/dart-format",
    description = "Replace the whitespace in your program with formatting that follows Dart guidelines.",
  },
  command = "dart",
  args = { "format" },
}
