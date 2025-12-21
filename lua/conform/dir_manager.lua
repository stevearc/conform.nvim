local log = require("conform.log")
local uv = vim.uv or vim.loop

local M = {}

---Set of directories that have been created
---@type string[]
M._dirs = {}

---Ensure that all parent directories of a path exist
---@param path string
M.ensure_parent = function(path)
  local current_parent_dir = vim.fs.dirname(path)
  -- Keep track of the current parent directories created, so we can delete them later
  while current_parent_dir and not uv.fs_stat(current_parent_dir) do
    table.insert(M._dirs, current_parent_dir)
    current_parent_dir = vim.fs.dirname(current_parent_dir)
  end
  vim.fn.mkdir(vim.fs.dirname(path), "p")
end

---Clean up temporary directories
M.cleanup = function()
  -- Before cleanup we make sure to order the deepest paths first
  table.sort(M._dirs, function(a, b)
    return a:len() > b:len()
  end)
  local temp_dir_idx = 1
  while temp_dir_idx <= #M._dirs do
    local temp_dir_to_remove = M._dirs[temp_dir_idx]
    log.trace("Cleaning up temp dir %s", temp_dir_to_remove)
    local success, err_name, err_msg = uv.fs_rmdir(temp_dir_to_remove)
    if not success then
      log.warn("Failed to remove temp directory %s: %s: %s", temp_dir_to_remove, err_name, err_msg)
      temp_dir_idx = temp_dir_idx + 1
    else
      table.remove(M._dirs, temp_dir_idx)
    end
  end
end

return M
