---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/rust-lang/rustfmt",
    description = "A tool for formatting rust code according to style guidelines.",
  },
  command = "rustfmt",
  options = {
    -- The default edition of Rust to use when no Cargo.toml file is found
    default_edition = "2021",
  },
  args = function(self, ctx)
    local args = { "--emit=stdout" }
    local manifest = vim.fs.find("Cargo.toml", { upward = true, path = ctx.dirname })[1]
    if manifest then
      table.insert(args, "--manifest-path=" .. manifest)
    elseif self.options.default_edition then
      table.insert(args, "--edition=" .. self.options.default_edition)
    end
    return args
  end,
}
