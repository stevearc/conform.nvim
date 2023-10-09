---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://www.gnu.org/software/gawk/manual/gawk.html",
    description = "Trim new lines with awk.",
  },
  command = "awk",
  args = { 'NF{print s $0; s=""; next} {s=s ORS}' },
}
