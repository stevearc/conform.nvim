---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://pypi.org/project/docformatter/",
    description = "docformatter automatically formats docstrings to follow a subset of the PEP 257 conventions.",
  },
  command = "docformatter",
  args = { "--in-place", "$FILENAME" },
  stdin = false,
  exit_codes = { 0, 3 },
}
