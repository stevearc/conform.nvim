---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://docs.astral.sh/ruff/",
    description = "An extremely fast Python linter, written in Rust. Organize imports.",
  },
  command = "ruff",
  args = {
    "check",
    "--fix",
    "--force-exclude",
    "--select=I001",
    "--exit-zero",
    "--no-cache",
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
