---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/mvdan/sh",
    description = "A shell parser, formatter, and interpreter with `bash` support.",
  },
  command = "shfmt",
  args = function(_, ctx)
    local args = { "-filename", "$FILENAME" }
    local bo = vim.bo[ctx.buf]
    if bo.expandtab then
      local indent_size = bo.shiftwidth
      if indent_size == 0 or not indent_size then
        indent_size = bo.tabstop or 2
      end
      vim.list_extend(args, { "-i", tostring(indent_size) })
    end
    return args
  end,
}
