local M = {}

local uv = vim.uv or vim.loop

---@type boolean
M.is_windows = uv.os_uname().version:match("Windows")

M.is_mac = uv.os_uname().sysname == "Darwin"

---@type string
M.sep = M.is_windows and "\\" or "/"

---@param ... string
M.join = function(...)
  return table.concat({ ... }, M.sep)
end

---@param filepath string
---@return boolean
M.exists = function(filepath)
  local stat = uv.fs_stat(filepath)
  return stat ~= nil and stat.type ~= nil
end

---@param filepath string
---@return string?
M.read_file = function(filepath)
  if not M.exists(filepath) then
    return nil
  end
  local fd = assert(uv.fs_open(filepath, "r", 420)) -- 0644
  local stat = assert(uv.fs_fstat(fd))
  local content = uv.fs_read(fd, stat.size)
  uv.fs_close(fd)
  return content
end

return M
