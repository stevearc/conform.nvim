---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/realm/SwiftLint",
    description = "A tool to enforce Swift style and conventions.",
  },
  command = "swiftlint",
  stdin = true,
  args = { "lint", "--use-stdin", "--fix", "--format" },
  cwd = require("conform.util").root_file({ ".swiftlint.yml", "Package.swift" }),
}
