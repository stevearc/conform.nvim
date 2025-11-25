---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/florianschanda/miss_hit",
    description = "A simple coding style checker and code formatter for MATLAB or Octave code.",
  },
  command = "mh_style",
  args = { "--fix", "$FILENAME" },
  stdin = false,
  exit_codes = { 0, 1 },
}
