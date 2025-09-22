---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/numtide/treefmt",
    description = "one CLI to format your repo.",
  },
  command = "treefmt",
  args = { "--stdin", "$FILENAME" },
  require_cwd = true,
  cwd = require("conform.util").root_file({ "treefmt.toml", ".treefmt.toml" }),
}
