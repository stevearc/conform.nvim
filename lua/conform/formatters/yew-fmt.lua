local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/schvv31n/yew-fmt",
    description = "Code formatter for the Yew framework.",
  },
  command = "yew-fmt",
  options = {
    -- The default edition of Rust to use when no Cargo.toml file is found
    default_edition = "2021",
  },
  args = function(self, ctx)
    local args = { "--emit=stdout" }
    local edition = util.parse_rust_edition(ctx.dirname) or self.options.default_edition
    table.insert(args, "--edition=" .. edition)

    return args
  end,
  cwd = util.root_file({
    "rustfmt.toml",
    ".rustfmt.toml",
  }),
}
