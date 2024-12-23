---@type conform.FileLuaFormatterConfig
return {
  meta = {
    url = "https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/equalprg.lua",
    description = "Vim's own equalprg",
  },
  format = function(self, ctx, lines, callback)
    local cursor_position = vim.api.nvim_win_get_cursor(0)
    if ctx.range then
      vim.cmd.normal(ctx.range["start"][1] .. "G")
      vim.cmd.normal("=" .. ctx.range["end"][1] .. "G")
    else
      vim.cmd.normal("gg")
      vim.cmd.normal("=G")
    end
    vim.api.nvim_win_set_cursor(0, cursor_position)
    callback(nil, nil)
  end,
}
