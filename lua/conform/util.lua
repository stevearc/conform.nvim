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

---@param bufnr integer
---@param range conform.Range
---@return integer start_offset
---@return integer end_offset
M.get_offsets_from_range = function(bufnr, range)
  local row = range.start[1] - 1
  local end_row = range["end"][1] - 1
  local col = range.start[2]
  local end_col = range["end"][2]
  local start_offset = vim.api.nvim_buf_get_offset(bufnr, row) + col
  local end_offset = vim.api.nvim_buf_get_offset(bufnr, end_row) + end_col
  return start_offset, end_offset
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

---@param cb fun(...)
---@param wrapper fun(...)
---@return fun(...)
M.wrap_callback = function(cb, wrapper)
  return function(...)
    wrapper(...)
    cb(...)
  end
end

return M
