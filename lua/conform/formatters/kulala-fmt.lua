---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/mistweaverco/kulala-fmt",
    description = "An opinionated .http and .rest files linter and formatter.",
  },
  command = "kulala-fmt",
  args = { "format", "$FILENAME" },
  stdin = false,
}
