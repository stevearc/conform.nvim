---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/mesonbuild/meson",
    description = "Format meson source file",
  },
  command = "meson",
  args = { "format", "--source-file-path", "$FILENAME", "-" },
}
