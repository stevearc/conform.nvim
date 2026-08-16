---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/mstdokumaci/zsort",
    description = "Sort and group @import declarations in Zig source.",
  },
  command = "zsort",
  args = { "fix" },
  stdin = false,
}