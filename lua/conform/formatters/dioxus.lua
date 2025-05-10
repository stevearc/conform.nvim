local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/dioxuslabs/dioxus",
    description = "Format `rsx!` snippets in Rust files.",
  },
  stdin = false,
  command = "dx",
  args = { "fmt", "--file", "$FILENAME" },
  cwd = util.root_file({ "Dioxus.toml" }),
}
