---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/daixiang0/gci",
    description = "GCI, a tool that controls Go package import order and makes it always deterministic.",
  },
  command = "gci",
  args = { "write", "--skip-generated", "--skip-vendor", "$FILENAME" },
  stdin = false,
}
