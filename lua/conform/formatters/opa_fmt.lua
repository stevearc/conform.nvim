---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://www.openpolicyagent.org/docs/latest/cli/#opa-fmt",
    description = "Format Rego files using `opa fmt` command.",
  },
  command = "opa",
  args = { "fmt" },
}
