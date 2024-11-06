---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://www.gnu.org/software/gawk/manual/gawk.html",
    description = "Format awk programs with awk",
  },
  command = "awk",
  args = { "-f", "-", "-o-" },
}
