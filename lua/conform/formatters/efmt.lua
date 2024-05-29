---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/sile/efmt",
    description = "Erlang code formatter.",
  },
  command = "efmt",
  args = { "-" },
  stdin = true,
}
