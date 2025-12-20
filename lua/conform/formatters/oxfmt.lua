local util = require("conform.util")

local config_file_names = {
  -- https://oxc.rs/docs/guide/usage/formatter.html#configuration-file
  ".oxfmtrc.json",
  ".oxfmtrc.jsonc",
}

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/oxc-project/oxc",
    description = "A Prettier-compatible code formatter.",
  },
  command = util.from_node_modules("oxfmt"),
  args = { "--stdin-filepath", "$FILENAME" },
  stdin = true,
  cwd = require("conform.util").root_file(config_file_names),
}
