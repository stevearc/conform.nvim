---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/frescobaldi/python-ly",
    description = "A Python package and commandline tool to manipulate LilyPond files.",
  },
  command = "ly",
  args = { "reformat", "$FILENAME", "-o", "$FILENAME" },
  stdin = false,
}
