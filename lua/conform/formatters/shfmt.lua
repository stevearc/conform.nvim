---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/mvdan/sh",
    description = "A shell parser, formatter, and interpreter with `bash` support.",
  },
  command = "shfmt",
  args = function(_, ctx)
    local args = { "-filename", "$FILENAME" }
    if vim.bo[ctx.buf].expandtab then
      vim.list_extend(args, { "-i", ctx.shiftwidth })
    end
    return args
  end,
}
