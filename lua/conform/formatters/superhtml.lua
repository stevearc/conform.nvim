---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/kristoff-it/superhtml",
    description = "HTML Language Server and Templating Language Library.",
  },
  command = "superhtml",
  args = { "fmt", "--stdin" },
}
