---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/FlamingTempura/bibtex-tidy",
    description = "Cleaner and Formatter for BibTeX files.",
  },
  command = "bibtex-tidy",
  stdin = true,
  args = { "--quiet" },
}
