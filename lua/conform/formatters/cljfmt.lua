local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/weavejester/cljfmt",
    description = "cljfmt is a tool for detecting and fixing formatting errors in Clojure code",
  },
  command = util.find_executable({
    "/usr/local/bin/cljfmt",
  }, "cljfmt"),
  args = { "fix", "$FILENAME" },
  stdin = false,
}
