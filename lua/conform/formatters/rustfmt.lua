---@param manifest string
---@return nil|string
local function parse_edition(manifest)
  for line in io.lines(manifest) do
    if line:match("^edition *=") then
      local edition = line:match("%d+")
      if edition then
        return edition
      end
    end
  end
end

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
    local edition
    local manifest = vim.fs.find("Cargo.toml", { upward = true, path = ctx.dirname })[1]
    if manifest then
      edition = parse_edition(manifest)
    end
    if not edition then
      edition = self.options.default_edition
    end
    table.insert(args, "--edition=" .. edition)

    return args
  end,
}
