---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/hougesen/mdsf",
    description = "Format markdown code blocks using your favorite code formatters.",
  },
  command = "mdsf",
  args = { "format", "$FILENAME" },
  stdin = false,
}
