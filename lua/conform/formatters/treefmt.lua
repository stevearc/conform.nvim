-- Do not pass the files via stdin because, when `treefmt` is run with the
-- `--stdin` flag, it copies stdin to a temporary file in `/tmp`, runs
-- configured formatters on it, and prints the file's content to stdout. This,
-- in turn, breaks formatters like, e.g.:
--
--  * `fourmolu`: it looks for `fourmolu.yaml` config files in the parent
--    directories of the file to be formatted.
--    (see https://github.com/fourmolu/fourmolu/issues/497#issuecomment-3679465883)
--
--  * `cabal-gild`: its automatic module discovery relies on the `*.cabal` file
--    being located in the project root.
--    (see https://github.com/tfausak/cabal-gild#discover)
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/numtide/treefmt",
    description = "one CLI to format your repo.",
  },
  command = "treefmt",
  args = { "$FILENAME" },
  stdin = false,
  require_cwd = true,
  cwd = require("conform.util").root_file({ "treefmt.toml", ".treefmt.toml" }),
}
