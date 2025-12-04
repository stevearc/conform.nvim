---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/numtide/treefmt",
    description = "one CLI to format your repo.",
  },
  command = "treefmt",
  args = { "--stdin", "$FILENAME" },
}
