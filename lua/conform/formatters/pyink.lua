---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/google/pyink",
    description = "Pyink, pronounced pī-ˈiŋk, is a Python formatter, forked from Black with a few different formatting behaviors.",
  },
  command = "pyink",
  args = {
    "--stdin-filename",
    "$FILENAME",
    "--quiet",
    "-",
  },
  stdin = true,
}
