---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/ocaml/dune",
    description = "Auto-formatter for Dune files.",
  },
  command = "dune",
  args = { "format-dune-file" },
  stdin = true,
}
