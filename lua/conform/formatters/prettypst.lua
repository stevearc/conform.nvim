---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/antonWetzel/prettypst",
    description = "Formatter for Typst.",
  },
  command = "prettypst",
  args = { "--use-std-in", "--use-std-out" },
  stdin = true,
}
