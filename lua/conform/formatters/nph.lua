---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/arnetheduck/nph",
    description = "An opinionated code formatter for Nim.",
  },
  command = "nph",
  stdin = true,
  args = { "-" },
}
