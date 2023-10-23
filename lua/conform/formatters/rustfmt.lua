---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/rust-lang/rustfmt",
    description = "A tool for formatting rust code according to style guidelines.",
  },
  command = "cargo",
	args = { "fmt", "--", "-q", "--emit=stdout" },
}
