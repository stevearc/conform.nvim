---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/swiftlang/swift-format",
    description = "Official Swift formatter. For Swift 6.0 or later prefer setting the `swift` formatter instead.",
  },
  command = "swift-format",
  args = { "$FILENAME", "--in-place" },
  stdin = false,
}
