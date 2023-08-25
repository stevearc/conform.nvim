local M = {}

---@param cmd string
---@return fun(ctx: conform.Context): string
M.from_node_modules = function(cmd)
  return function(ctx)
    local fs = require("conform.fs")
    local found =
      vim.fs.find("node_modules", { upward = true, type = "directory", path = ctx.dirname })
    for _, dir in ipairs(found) do
      local executable = fs.join(dir, ".bin", cmd)
      if vim.fn.executable(executable) == 1 then
        return executable
      end
    end
    return cmd
  end
end

---@param files string|string[]
---@return fun(ctx: conform.Context): nil|string
M.root_file = function(files)
  return function(ctx)
    local found = vim.fs.find(files, { upward = true, path = ctx.dirname })[1]
    if found then
      return vim.fs.dirname(found)
    end
  end
end

---@param bufnr? integer
---@return fun() Function that restores the window positions
M.save_win_positions = function(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local win_positions = {}
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(winid) == bufnr then
      vim.api.nvim_win_call(winid, function()
        local view = vim.fn.winsaveview()
        win_positions[winid] = view
      end)
    end
  end

  return function()
    for winid, view in pairs(win_positions) do
      vim.api.nvim_win_call(winid, function()
        pcall(vim.fn.winrestview, view)
      end)
    end
  end
end

---@generic T : any
---@param tbl T[]
---@param start_idx? number
---@param end_idx? number
---@return T[]
M.tbl_slice = function(tbl, start_idx, end_idx)
  local ret = {}
  if not start_idx then
    start_idx = 1
  end
  if not end_idx then
    end_idx = #tbl
  end
  for i = start_idx, end_idx do
    table.insert(ret, tbl[i])
  end
  return ret
end

return M
