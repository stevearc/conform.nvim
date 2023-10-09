---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://buf.build/docs/reference/cli/buf/format",
    description = "A new way of working with Protocol Buffers.",
  },
  command = "buf",
  args = { "format", "-w", "$FILENAME" },
  stdin = false,
  cwd = require("conform.util").root_file({ "buf.yaml" }),
}
