---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://golangci-lint.run/usage/configuration/#fmt",
    description = "A golang linter and formatter.",
  },
  command = "golangci-lint",
  args = { "fmt", "--stdin" },
}
