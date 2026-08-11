---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/muon-build/muon",
    description = "Format meson source files.",
  },
  command = "muon",
  args = { "fmt", "-e", "$FILENAME" },
}
