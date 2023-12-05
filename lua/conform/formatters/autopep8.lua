---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/hhatto/autopep8",
    description = "A tool that automatically formats Python code to conform to the PEP 8 style guide.",
  },
  command = "autopep8",
  args = { "-" },
  range_args = function(self, ctx)
    return { "-", "--line-range", tostring(ctx.range.start[1]), tostring(ctx.range["end"][1]) }
  end,
}
