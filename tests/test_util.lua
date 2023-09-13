require("plenary.async").tests.add_to_env()
local conform = require("conform")
local log = require("conform.log")
local M = {}

local OUTPUT_FILE = "tests/fake_formatter_output"

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
  if vim.fn.filereadable(OUTPUT_FILE) == 1 then
    vim.fn.delete(OUTPUT_FILE)
  end
  log.level = vim.log.levels.ERROR
  log.set_handler(print)
end

---@param lines string[]
M.set_formatter_output = function(lines)
  local content = table.concat(lines, "\n")
  local fd = assert(vim.loop.fs_open(OUTPUT_FILE, "w", 420)) -- 0644
  vim.loop.fs_write(fd, content)
  -- Make sure we add the final newline
  vim.loop.fs_write(fd, "\n")
  vim.loop.fs_close(fd)
end

return M
