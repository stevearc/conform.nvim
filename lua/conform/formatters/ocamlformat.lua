---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/ocaml-ppx/ocamlformat",
    description = "Auto-formatter for OCaml code.",
  },
  command = "ocamlformat",
  args = { "--enable-outside-detected-project", "--name", "$FILENAME", "-" },
}
