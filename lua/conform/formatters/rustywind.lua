---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/avencera/rustywind",
    description = "Inspired by Ryan Heybourn's headwind vscode plugin. This is a CLI tool that will look through your project and sort all Tailwind CSS classes. It will also delete any duplicate classes it finds.",
  },
  command = "rustywind",
  args = { "--stdin" },
}
