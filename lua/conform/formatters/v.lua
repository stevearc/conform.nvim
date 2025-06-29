---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://vlang.io",
    description = "V language formatter.",
  },
  command = "v",
  args = { "fmt", "-w", "$FILENAME" },
  stdin = false,
}
