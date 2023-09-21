---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://beta.ruff.rs/docs/",
    description = "An extremely fast Python linter, written in Rust. Fix lint errors.",
  },
  command = "ruff",
  args = {
    "--fix",
    "-e",
    "-n",
    "--stdin-filename",
    "$FILENAME",
    "-",
  },
  stdin = true,
  cwd = require("conform.util").root_file({
    "pyproject.toml",
    "ruff.toml",
  }),
}
