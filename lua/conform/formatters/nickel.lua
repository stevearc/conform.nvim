---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://nickel-lang.org/",
    description = "Code formatter for the Nickel programming language.",
  },
  command = "nickel",
  stdin = false,
  args = { "format", "$FILENAME" },
}
