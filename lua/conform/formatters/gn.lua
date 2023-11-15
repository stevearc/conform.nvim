---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://gn.googlesource.com/gn/",
    description = "gn build system.",
  },
  command = "gn",
  args = { "format", "--stdin" },
}
