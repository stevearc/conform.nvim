---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://www.terraform.io/docs/cli/commands/fmt.html",
    description = "The terraform-fmt command rewrites `terraform` configuration files to a canonical format and style.",
  },
  command = "terraform",
  args = { "fmt", "-" },
}
