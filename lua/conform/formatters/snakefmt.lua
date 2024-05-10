---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/snakemake/snakefmt",
    description = "a formatting tool for Snakemake files following the design of Black.",
  },
  command = "snakefmt",
  args = "$FILENAME",
  stdin = false,
}
