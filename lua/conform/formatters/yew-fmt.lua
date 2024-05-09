-- yew-fmt is a fork of rustfmt
local rustfmt = require("conform.formatters.rustfmt")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/schvv31n/yew-fmt",
    description = "Code formatter for the Yew framework.",
  },
  command = "yew-fmt",
  options = {
    -- The default edition of Rust to use when no Cargo.toml file is found
    default_edition = rustfmt.default_edition,
  },
  args = rustfmt.args,
}
