---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://docs.astral.sh/ruff/",
    description = "An extremely fast Python linter, written in Rust. Formatter subcommand.",
  },
  command = "ruff",
  args = {
    "format",
    "--force-exclude",
    "--stdin-filename",
    "$FILENAME",
    "-",
  },
  stdin = true,
  cwd = require("conform.util").root_file({
    "pyproject.toml",
    "ruff.toml",
    ".ruff.toml",
  }),
}
