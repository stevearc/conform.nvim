---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://developer.hashicorp.com/nomad/docs/commands/fmt",
    description = "The fmt commands check the syntax and rewrites Nomad configuration and jobspec files to canonical format.",
  },
  command = "nomad",
  args = { "fmt", "-" },
}
