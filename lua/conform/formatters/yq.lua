---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/mikefarah/yq",
    description = "YAML/JSON processor",
  },
  command = "yq",
  args = { "-P", "-" },
  stdin = true,
}
