---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/google/go-jsonnet/cmd/jsonnetfmt",
    description = "yamlfmt is a command line tool to format jsonnet files.",
  },
  command = "jsonnetfmt",
  args = { "$FILENAME" },
}
