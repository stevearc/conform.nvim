---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/ziglang/zig",
    description = "Reformat Zig source into canonical form.",
  },
  command = "zig",
  args = { "fmt", "--stdin" },
}
