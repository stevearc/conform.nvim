---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/uncrustify/uncrustify",
    description = "A source code beautifier for C, C++, C#, ObjectiveC, D, Java, Pawn and Vala.",
  },
  command = "uncrustify",
  args = function(self, ctx)
    local config_name = "uncrustify.cfg"
    local args = { "-q", "-l", vim.bo[ctx.buf].filetype:upper() }

    -- Find uncrustify.cfg in the project if it exists
    local cfg_path = require("conform.util").root_file(config_name)(self, ctx)
    if cfg_path then
      table.insert(args, "-c")
      table.insert(args, cfg_path .. require("conform.fs").sep .. config_name)
    end
    return args
  end,
}
