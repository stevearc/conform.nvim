---@type conform.FileLuaFormatterConfig
return {
  meta = {
    url = "https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/equalprg.lua",
    description = "Vim's own equalprg",
  },
  format = function(self, ctx, lines, callback)
    local cursor_position = vim.api.nvim_win_get_cursor(0)
    vim.cmd.normal("gg")
    vim.cmd.normal("=G")
    vim.api.nvim_win_set_cursor(0, cursor_position)
    callback(nil, nil)
  end,
}
