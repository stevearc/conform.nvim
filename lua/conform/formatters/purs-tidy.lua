---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/natefaubion/purescript-tidy",
    description = "A syntax tidy-upper for PureScript.",
  },
  command = "purs-tidy",
  args = { "format" },
  stdin = true,
}
