local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust/tree/main/crates/emmylua_formatter",
    description = "The Lua and EmmyLua formatter from EmmyLua Analyzer Rust.",
  },
  command = "luafmt",
  args = { "--stdin" },
  stdin = true,
  cwd = util.root_file({
    ".luafmt.toml",
    "luafmt.toml",
  }),
}
