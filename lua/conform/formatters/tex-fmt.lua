---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/WGUNDERWOOD/tex-fmt",
    description = "An extremely fast LaTeX formatter written in Rust.",
  },
  command = "tex-fmt",
  args = function(self, ctx)
    local spaces = vim.bo[ctx.buf].expandtab

    local args = {
      "--stdin",
      "--tabsize",
      spaces and ctx.shiftwidth or 1,
    }

    if not spaces then
      table.insert(args, "--usetabs")
    end

    return args
  end,
}
