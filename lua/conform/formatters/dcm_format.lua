---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://dcm.dev/docs/cli/formatting/format/",
    description = "Formats .dart files.",
  },
  command = "dcm",
  args = { "format", "$FILENAME" },
  stdin = false,
}
