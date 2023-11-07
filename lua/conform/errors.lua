local M = {}

---@class conform.Error
---@field code conform.ERROR_CODE
---@field message string
---@field debounce_message? boolean

---@enum conform.ERROR_CODE
M.ERROR_CODE = {
  -- Command was passed invalid arguments
  INVALID_ARGS = 1,
  -- Command was not executable
  NOT_EXECUTABLE = 2,
  -- Error occurred during when calling jobstart
  JOBSTART = 3,
  -- Command timed out during execution
  TIMEOUT = 4,
  -- Command was pre-empted by another call to format
  INTERRUPTED = 5,
  -- Command produced an error during execution
  RUNTIME = 6,
  -- Asynchronous formatter results were discarded due to a concurrent modification
  CONCURRENT_MODIFICATION = 7,
}

---@param code conform.ERROR_CODE
---@return integer
M.level_for_code = function(code)
  if code == M.ERROR_CODE.CONCURRENT_MODIFICATION then
    return vim.log.levels.INFO
  elseif code == M.ERROR_CODE.TIMEOUT or code == M.ERROR_CODE.INTERRUPTED then
    return vim.log.levels.WARN
  else
    return vim.log.levels.ERROR
  end
end

---Returns true if the error occurred while attempting to run the formatter
---@param code conform.ERROR_CODE
---@return boolean
M.is_execution_error = function(code)
  return code == M.ERROR_CODE.RUNTIME
    or code == M.ERROR_CODE.NOT_EXECUTABLE
    or code == M.ERROR_CODE.INVALID_ARGS
    or code == M.ERROR_CODE.JOBSTART
end

---@param err1? conform.Error
---@param err2? conform.Error
---@return nil|conform.Error
M.coalesce = function(err1, err2)
  if not err1 then
    return err2
  elseif not err2 then
    return err1
  end
  local level1 = M.level_for_code(err1.code)
  local level2 = M.level_for_code(err2.code)
  if level2 > level1 then
    return err2
  else
    return err1
  end
end

return M
