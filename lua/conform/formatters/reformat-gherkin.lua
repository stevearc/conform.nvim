---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/ducminh-phan/reformat-gherkin",
    description = "Reformat-gherkin automatically formats Gherkin files",
  },
  command = "reformat-gherkin",
  args = { "-" },
  stdin = true,
}
