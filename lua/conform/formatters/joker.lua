---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/candid82/joker",
    description = "Small Clojure interpreter, linter and formatter.",
  },
  command = "joker",
  args = { "--format", "--write", "-" },
}
