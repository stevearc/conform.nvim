---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/nicklockwood/SwiftFormat",
    description = "SwiftFormat is a code library and command-line tool for reformatting `swift` code on macOS or Linux.",
  },
  command = "swiftformat",
  stdin = true,
  args = { "--stdinpath", "$FILENAME" },
  range_args = function(self, ctx)
    local startOffset = ctx.range.start[1]
    local endOffset = ctx.range["end"][1]

    return {
      "--linerange",
      startOffset .. "," .. endOffset,
      "--stdinpath",
      "$FILENAME",
    }
  end,
  cwd = require("conform.util").root_file({ ".swiftformat", "Package.swift", "buildServer.json" }),
}
