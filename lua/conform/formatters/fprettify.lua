---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/fortran-lang/fprettify",
    description = "Auto-formatter for modern fortran source code.",
  },
  command = "fprettify",
  args = {
    -- --silent is recommended for editor integrations https://github.com/fortran-lang/fprettify?tab=readme-ov-file#editor-integration
    "--silent",
    "-",
  },
  stdin = true,
}
