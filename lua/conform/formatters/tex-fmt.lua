---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/WGUNDERWOOD/tex-fmt",
    description = "An extremely fast LaTeX formatter written in Rust.",
  },
  command = "tex-fmt",
  args = function(self, ctx)
    local args = {
      "--stdin",
      "--tabsize",
      ctx.shiftwidth,
    }

    if not vim.bo[ctx.buf].expandtab then
      table.insert(args, "--usetabs")
    end

    return args
  end,
}
