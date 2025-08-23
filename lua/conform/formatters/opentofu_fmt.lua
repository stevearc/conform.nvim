---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://opentofu.org/docs/cli/commands/fmt/",
    description = "The opentofu_fmt command rewrites `terraform/tofu` configuration files to a canonical format and style.",
  },
  command = "tofu",
  args = { "fmt", "-no-color", "-" },
}
