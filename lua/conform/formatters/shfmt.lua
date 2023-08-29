---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/mvdan/sh",
    description = "A shell parser, formatter, and interpreter with `bash` support.",
  },
  command = "shfmt",
  args = { "-filename", "$FILENAME" },
}
