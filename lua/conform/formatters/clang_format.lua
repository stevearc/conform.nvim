local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://www.kernel.org/doc/html/latest/process/clang-format.html",
    description = "Tool to format C/C++/… code according to a set of rules and heuristics.",
  },
  command = "clang-format",
  args = { "-assume-filename", "$FILENAME" },
  range_args = function(self, ctx)
    local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
    local length = end_offset - start_offset
    return {
      "-assume-filename",
      "$FILENAME",
      "--offset",
      tostring(start_offset),
      "--length",
      tostring(length),
    }
  end,
}
