---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/carthage-software/mago",
    description = "Mago is a toolchain for PHP that aims to provide a set of tools to help developers write better code.",
  },
  command = "mago",
  stdin = false,
  args = { "lint", "--fix", "--format", "$FILENAME" },
}
