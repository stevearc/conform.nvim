---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/cmhughes/latexindent.pl",
    description = "A perl script for formatting LaTeX files that is generally included in major TeX distributions.",
  },
  command = "latexindent",
  args = { "-" },
  range_args = function(_, ctx)
    return { "--lines", ctx.range.start[1] .. "-" .. ctx.range["end"][1], "-" }
  end,
  stdin = true,
}
