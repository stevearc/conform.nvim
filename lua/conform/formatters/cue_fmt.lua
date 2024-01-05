---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://cuelang.org",
    description = "Format CUE files using `cue fmt` command.",
  },
  command = "cue",
  args = { "fmt", "-" },
  stdin = true,
}
