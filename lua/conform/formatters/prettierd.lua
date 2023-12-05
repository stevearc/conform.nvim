local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/fsouza/prettierd",
    description = "prettier, as a daemon, for ludicrous formatting speed.",
  },
  command = util.from_node_modules("prettierd"),
  args = { "$FILENAME" },
  range_args = function(self, ctx)
    local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
    return { "$FILENAME", "--range-start=" .. start_offset, "--range-end=" .. end_offset }
  end,
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
