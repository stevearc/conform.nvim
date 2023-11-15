---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://developer.hashicorp.com/packer/docs/commands/fmt",
    description = "The packer fmt Packer command is used to format HCL2 configuration files to a canonical format and style.",
  },
  command = "packer",
  args = { "fmt", "-" },
}
