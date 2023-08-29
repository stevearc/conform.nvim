---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/nicklockwood/SwiftFormat",
    description = "SwiftFormat is a code library and command-line tool for reformatting `swift` code on macOS or Linux.",
  },
  command = "swiftformat",
  args = { "--stdinpath", "$FILENAME" },
}
