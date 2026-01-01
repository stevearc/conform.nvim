---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/rvben/rumdl",
    description = "Markdown Linter and Formatter written in Rust.",
  },
  command = "rumdl",
  args = { "fmt", "-" },
  stdin = true,
}
