local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/akaihola/darker",
    description = "Run black only on changed lines.",
  },
  command = "darker",
  args = function(self, ctx)
    -- make sure pre-save doesn't lose changes while post-save respects
    -- the revision setting potentially set in pyproject.toml
    if vim.bo[ctx.buf].modified then
      return {
        "--quiet",
        "--no-color",
        "--stdout",
        "--revision",
        "HEAD..:STDIN:",
        "--stdin-filename",
        "$FILENAME",
      }
    else
      return {
        "--quiet",
        "--no-color",
        "--stdout",
        "$FILENAME",
      }
    end
  end,
  cwd = util.root_file({
    -- https://github.com/akaihola/darker#customizing-darker-black-isort-flynt-and-linter-behavior
    "pyproject.toml",
  }),
}
