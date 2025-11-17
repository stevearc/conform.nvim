---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/stedolan/jq",
    description = "Command-line JSON processor.",
  },
  command = "jq",
  args = function(_, ctx)
    return { "--indent", math.max(-1, math.min(7, ctx.shiftwidth)) }
  end,
}
