---@type conform.FileLuaFormatterConfig
return {
  meta = {
    url = "https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/trim_whitespace.lua",
    description = "Trim trailing whitespace.",
  },
  format = function(self, ctx, lines, callback)
    local out_lines = {}
    for _, line in ipairs(lines) do
      local trimmed = line:gsub("%s+$", "")
      table.insert(out_lines, trimmed)
    end
    callback(nil, out_lines)
  end,
}
