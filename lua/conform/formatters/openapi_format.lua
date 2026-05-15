local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/thim81/openapi-format",
    description = "Format an OpenAPI document by ordering, formatting and filtering fields.",
  },
  command = "openapi-format",
  args = { "$FILENAME", "--output", "$FILENAME" },
  stdin = false,
  cwd = util.root_file({ ".openapiformatrc" }),
}
