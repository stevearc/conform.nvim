local util = require("conform.util")
---@type conform.FormatterConfig
return {
  meta = {
    url = "https://github.com/fsouza/prettierd",
    description = "prettier, as a daemon, for ludicrous formatting speed.",
  },
  command = util.from_node_modules("prettierd"),
  args = { "$FILENAME" },
  cwd = util.root_file({
    -- https://prettier.io/docs/en/configuration.html
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.json5",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.toml",
    "prettier.config.js",
    "prettier.config.cjs",
    "package.json",
  }),
}
