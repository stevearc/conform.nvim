---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/uncrustify/uncrustify",
    description = "A source code beautifier for C, C++, C#, ObjectiveC, D, Java, Pawn and Vala.",
  },
  command = "uncrustify",
  args = function(_, ctx)
    local args = { "-q", "-l", vim.bo[ctx.buf].filetype:upper() }

    -- Find uncrustify.cfg in the project if it exists
    local cfg_path = vim.fs.find("uncrustify.cfg", { upward = true, path = ctx.dirname })[1]
    if cfg_path then
      table.insert(args, "-c")
      table.insert(args, cfg_path)
    end
    return args
  end,
}
