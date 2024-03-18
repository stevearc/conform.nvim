---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/roc-lang/roc",
    description = "A fast, friendly, functional language.",
  },
  command = "roc",
  args = { "format", "--stdin", "--stdout" },
  stdin = true,
}
