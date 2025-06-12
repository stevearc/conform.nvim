---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://vlang.io",
    description = "Formats the given V codes",
  },
  command = "v",
  args = { "fmt", "-w", "$FILENAME" },
  stdin = false,
}
