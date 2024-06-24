---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://caramel.run/manual/reference/cli/fmt.html",
    description = "Format Caramel code.",
  },
  command = "caramel",
  args = { "fmt", "$FILENAME" },
  stdin = false,
}
