require("plenary.async").tests.add_to_env()
local conform = require("conform")
local log = require("conform.log")
local M = {}

M.reset_editor = function()
  vim.cmd.tabonly({ mods = { silent = true } })
  for i, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if i > 1 then
      vim.api.nvim_win_close(winid, true)
    end
  end
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(false, true))
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
  conform.formatters = {}
  conform.formatters_by_ft = {}
  pcall(vim.api.nvim_del_augroup_by_name, "Conform")
  log.level = vim.log.levels.ERROR
  log.set_handler(print)
end

return M
