---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/avh4/elm-format",
    description = "elm-format formats Elm source code according to a standard set of rules based on the official [Elm Style Guide](https://elm-lang.org/docs/style-guide).",
  },
  command = "elm-format",
  args = { "--stdin" },
}
