---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/google/go-jsonnet/tree/master/cmd/jsonnetfmt",
    description = "jsonnetfmt is a command line tool to format jsonnet files.",
  },
  command = "jsonnetfmt",
  args = { "-" },
  stdin = true,
}
