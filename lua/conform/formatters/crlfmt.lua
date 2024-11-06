---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/cockroachdb/crlfmt",
    description = "Formatter for CockroachDB's additions to the Go style guide.",
  },
  command = "crlfmt",
  args = { "-w", "$FILENAME" },
  stdin = false,
}
