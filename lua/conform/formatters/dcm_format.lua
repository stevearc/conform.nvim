---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://dcm.dev/docs/cli/formatting/format/",
    description = "Formats .dart files.",
  },
  command = "dcm",
  args = { "format", "$FILENAME" },
  exit_codes = { 0, 2 },
  stdin = false,
}
