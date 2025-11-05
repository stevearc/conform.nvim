---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/apple/pkl",
    description = "Official canonical formatter for Pkl.",
  },
  command = "pkl",
  args = { "format", "-" },
  exit_codes = { 0, 11 },
}
