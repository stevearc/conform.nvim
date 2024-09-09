---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/kristoff-it/ziggy",
    description = "A data serialization language for expressing clear API messages, config files, etc.",
  },
  command = "ziggy",
  args = { "fmt", "--stdin-schema" },
}
