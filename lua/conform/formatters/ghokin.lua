---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/antham/ghokin",
    description = "Parallelized formatter with no external dependencies for gherkin.",
  },

  command = "ghokin",
  args = { "fmt", "stdout" },
}
