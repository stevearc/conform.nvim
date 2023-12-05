local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/JohnnyMorganz/StyLua",
    description = "An opinionated code formatter for Lua.",
  },
  command = "stylua",
  args = { "--search-parent-directories", "--stdin-filepath", "$FILENAME", "-" },
  range_args = function(self, ctx)
    local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
    return {
      "--search-parent-directories",
      "--stdin-filepath",
      "$FILENAME",
      "--range-start",
      tostring(start_offset),
      "--range-end",
      tostring(end_offset),
      "-",
    }
  end,
  cwd = util.root_file({
    ".stylua.toml",
    "stylua.toml",
  }),
}
