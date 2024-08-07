---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/weavejester/cljfmt",
    description = "cljfmt is a tool for detecting and fixing formatting errors in Clojure code.",
  },
  command = "cljfmt",
  args = { "fix", "-" },
  stdin = true,
}
