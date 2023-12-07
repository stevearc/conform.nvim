---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/uncrustify/uncrustify",
    description = "A source code beautifier for C, C++, C#, ObjectiveC, D, Java, Pawn and Vala.",
  },
  command = "uncrustify",
  args = function(self, ctx)
    return { "-q", "-l", vim.bo[ctx.buf].filetype:upper() }
  end,
}
