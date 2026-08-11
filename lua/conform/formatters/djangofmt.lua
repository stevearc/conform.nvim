---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/UnknownPlatypus/djangofmt",
    description = "A fast, HTML aware, Django template formatter, written in Rust.",
  },
  command = "djangofmt",
  args = { "--stdin-filename", "$FILENAME" },
  stdin = true,
}
