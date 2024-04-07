---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/Azure/bicep",
    description = "Bicep is a Domain Specific Language (DSL) for deploying Azure resources declaratively.",
  },
  command = "bicep",
  args = { "format", "--stdout", "$FILENAME" },
}
