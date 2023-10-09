---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://www.gnu.org/software/gawk/manual/gawk.html",
    description = "Trim whitespaces with awk.",
  },
  command = "awk",
  args = { '{ sub(/[ \t]+$/, ""); print }' },
}
