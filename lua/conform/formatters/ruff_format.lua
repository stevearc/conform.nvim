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
  range_args = function(self, ctx)
    return {
      "format",
      "--force-exclude",
      "--range",
      string.format(
        "%d:%d-%d:%d",
        ctx.range.start[1],
        ctx.range.start[2] + 1,
        ctx.range["end"][1],
        ctx.range["end"][2] + 1
      ),
      "--stdin-filename",
      "$FILENAME",
      "-",
    }
  end,
  stdin = true,
  cwd = require("conform.util").root_file({
    "pyproject.toml",
    "ruff.toml",
    ".ruff.toml",
  }),
}
