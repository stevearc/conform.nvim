---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://crystal-lang.org/",
    description = "Format Crystal code.",
  },
  command = "crystal",
  args = { "tool", "format", "-" },
  stdin = true,
}
