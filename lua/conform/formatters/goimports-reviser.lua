---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/incu6us/goimports-reviser",
    description = "Right imports sorting & code formatting tool (goimports alternative).",
  },
  command = "goimports-reviser",
  args = { "-format", "$FILENAME" },
  stdin = false,
}
