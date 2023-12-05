---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/google/yapf",
    description = "Yet Another Python Formatter.",
  },
  command = "yapf",
  args = { "--quiet" },
  range_args = function(self, ctx)
    return { "--quiet", "--lines", string.format("%d-%d", ctx.range.start[1], ctx.range["end"][1]) }
  end,
}
