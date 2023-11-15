---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://ast-grep.github.io/",
    description = "A CLI tool for code structural search, lint and rewriting. Written in Rust.",
  },
  command = "ast-grep",
  args = { "scan", "--update-all", "$FILENAME" },
  stdin = false,
  exit_codes = { 0, 5 }, -- 5 = no config file exists
}
