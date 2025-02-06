---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://docs.github.com/en/code-security/codeql-cli/codeql-cli-manual/query-format",
    description = "Format queries and libraries with CodeQL.",
  },
  command = "codeql",
  args = { "query", "format", "-" },
}
