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

---@generic T : fun()
---@param cb T
---@param wrapper T
---@return T
M.wrap_callback = function(cb, wrapper)
  return function(...)
    wrapper(...)
    cb(...)
  end
end

---Helper function to add to the default args of a formatter.
---@param args string|string[]|fun(ctx: conform.Context): string|string[]
---@param extra_args string|string[]|fun(ctx: conform.Context): string|string[]
---@param opts? { append?: boolean }
---@example
--- local util = require("conform.util")
--- local prettier = require("conform.formatters.prettier")
--- require("conform").formatters.prettier = vim.tbl_deep_extend("force", prettier, {
---   args = util.extend_args(prettier.args, { "--tab", "--indent", "2" }),
---   range_args = util.extend_args(prettier.range_args, { "--tab", "--indent", "2" }),
--- })
M.extend_args = function(args, extra_args, opts)
  opts = opts or {}
  return function(ctx)
    if type(args) == "function" then
      args = args(ctx)
    end
    if type(extra_args) == "function" then
      extra_args = extra_args(ctx)
    end
    if type(args) == "string" then
      if type(extra_args) ~= "string" then
        extra_args = table.concat(extra_args, " ")
      end
      if opts.append then
        return args .. " " .. extra_args
      else
        return extra_args .. " " .. args
      end
    else
      if type(extra_args) == "string" then
        error("extra_args must be a table when args is a table")
      end
      if opts.append then
        return vim.tbl_flatten({ args, extra_args })
      else
        return vim.tbl_flatten({ extra_args, args })
      end
    end
  end
end

---Helper function to return the first path that exists or fallback to a default.
---@param paths string[]
---@param default string
---@return string
---@example
---```lua
---return {
---  command = require('utils').path_or(
---    { 'vendor/bin/php-cs-fixer' },
---    'php-cs-fixer'
---  ),
---  args = { 'fix', '$FILENAME' },
---  stdin = false,
---}
---```
M.path_or = function(paths, default)
  for _, fname in ipairs(paths) do
    local path = vim.fn.fnamemodify(fname, ":p")
    if vim.loop.fs_stat(path) then
      return path
    end
  end
  return default
end

return M
