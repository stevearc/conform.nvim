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
    local startOffset = tonumber(ctx.range.start[1]) - 1
    local endOffset = tonumber(ctx.range["end"][1]) - 1

    return {
      "--linerange",
      startOffset .. "," .. endOffset,
    }
  end,
  cwd = require("conform.util").root_file({ ".swiftformat", "Package.swift", "buildServer.json" }),
}
