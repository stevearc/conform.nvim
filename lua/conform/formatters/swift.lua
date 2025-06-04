---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/swiftlang/swift-format",
    description = "Official Swift formatter. Requires Swift 6.0 or later.",
  },
  command = "swift",
  args = { "format", "$FILENAME", "--in-place" },
  stdin = false,
}
