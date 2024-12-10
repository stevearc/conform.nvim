---@type conform.FileLuaFormatterConfig
return {
  meta = {
    url = "https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/trim_newlines.lua",
    description = "Trim empty lines at the end of the file.",
  },
  format = function(self, ctx, lines, callback)
    local out_lines = vim.deepcopy(lines)
    while #out_lines > 0 and out_lines[#out_lines] == "" do
      table.remove(out_lines)
    end
    callback(nil, out_lines)
  end,
}
