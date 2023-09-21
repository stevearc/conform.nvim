---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/cmhughes/latexindent.pl",
    description = "A perl script for formatting LaTeX files that is generally included in major TeX distributions.",
  },
  command = "latexindent",
  args = { "-" },
  stdin = true,
}
