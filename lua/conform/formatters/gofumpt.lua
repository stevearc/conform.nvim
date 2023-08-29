---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/mvdan/gofumpt",
    description = "Enforce a stricter format than gofmt, while being backwards compatible. That is, gofumpt is happy with a subset of the formats that gofmt is happy with.",
  },
  command = "gofumpt",
}
