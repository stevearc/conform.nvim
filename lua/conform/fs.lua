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

M.is_absolute = function(path)
  if M.is_windows then
    return path:lower():match("^%a:")
  else
    return vim.startswith(path, "/")
  end
end

M.abspath = function(path)
  if not M.is_absolute(path) then
    path = vim.fn.fnamemodify(path, ":p")
  end
  return path
end

---Returns true if candidate is a subpath of root, or if they are the same path.
---@param root string
---@param candidate string
---@return boolean
M.is_subpath = function(root, candidate)
  if candidate == "" then
    return false
  end
  root = vim.fs.normalize(M.abspath(root))
  -- Trim trailing "/" from the root
  if root:find("/", -1) then
    root = root:sub(1, -2)
  end
  candidate = vim.fs.normalize(M.abspath(candidate))
  if M.is_windows then
    root = root:lower()
    candidate = candidate:lower()
  end
  if root == candidate then
    return true
  end
  local prefix = candidate:sub(1, root:len())
  if prefix ~= root then
    return false
  end

  local candidate_starts_with_sep = candidate:find("/", root:len() + 1, true) == root:len() + 1
  local root_ends_with_sep = root:find("/", root:len(), true) == root:len()

  return candidate_starts_with_sep or root_ends_with_sep
end

---Create a relative path from the source to the target
---@param source string
---@param target string
---@return string
M.relative_path = function(source, target)
  source = M.abspath(source)
  target = M.abspath(target)
  local path = {}
  while not M.is_subpath(source, target) do
    table.insert(path, "..")
    local new_source = vim.fs.dirname(source)

    -- If source is a root directory, we can't go up further so there is no relative path to the
    -- target. This should only happen on Windows, which prohibits relative paths between drives.
    if source == new_source then
      local log = require("conform.log")
      log.warn("Could not find relative path from %s to %s", source, target)
      return target
    end

    source = new_source
  end

  local offset = vim.endswith(source, M.sep) and 1 or 2
  local rel_target = target:sub(source:len() + offset)
  table.insert(path, rel_target)
  return M.join(unpack(path))
end

return M
