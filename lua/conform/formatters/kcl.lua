---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://www.kcl-lang.io/docs/tools/cli/kcl/fmt",
    description = "The KCL Format tool modifies the files according to the KCL code style.",
  },
  command = "kcl",
  args = { "fmt", "$FILENAME" },
  stdin = false,
}
