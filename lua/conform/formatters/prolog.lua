---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/jamesnvc/lsp_server",
    description = "Language Server Protocol server and formatter for SWI-Prolog.",
  },
  command = "swipl",
  args = { "formatter", "$FILENAME" },
  stdin = false,
}
