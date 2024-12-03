---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://www.gnu.org/software/gawk/manual/gawk.html",
    description = "Format awk programs with gawk.",
    deprecated = true,
  },
  command = "awk",
  args = { "-f", "-", "-o-" },
}
