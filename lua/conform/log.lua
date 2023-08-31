local uv = vim.uv or vim.loop
local levels = vim.deepcopy(vim.log.levels)
vim.tbl_add_reverse_lookup(levels)

local Log = {}

---@type integer
Log.level = vim.log.levels.WARN

---@return string
Log.get_logfile = function()
  local fs = require("conform.fs")

  local ok, stdpath = pcall(vim.fn.stdpath, "log")
  if not ok then
    stdpath = vim.fn.stdpath("cache")
  end
  return fs.join(stdpath, "conform.log")
end

---@param level integer
---@param msg string
---@param ... any[]
---@return string
local function format(level, msg, ...)
  local args = vim.F.pack_len(...)
  for i = 1, args.n do
    local v = args[i]
    if type(v) == "table" then
      args[i] = vim.inspect(v)
    elseif v == nil then
      args[i] = "nil"
    end
  end
  local ok, text = pcall(string.format, msg, vim.F.unpack_len(args))
  local timestr = vim.fn.strftime("%H:%M:%S")
  if ok then
    local str_level = levels[level]
    return string.format("%s[%s] %s", timestr, str_level, text)
  else
    return string.format(
      "%s[ERROR] error formatting log line: '%s' args %s",
      timestr,
      vim.inspect(msg),
      vim.inspect(args)
    )
  end
end

---@param line string
local function write(line)
  -- This will be replaced during initialization
end

local initialized = false
local function initialize()
  if initialized then
    return
  end
  initialized = true
  local filepath = Log.get_logfile()

  local stat = uv.fs_stat(filepath)
  if stat and stat.size > 10 * 1024 * 1024 then
    local backup = filepath .. ".1"
    uv.fs_unlink(backup)
    uv.fs_rename(filepath, backup)
  end

  local parent = vim.fs.dirname(filepath)
  vim.fn.mkdir(parent, "p")

  local logfile, openerr = io.open(filepath, "a+")
  if not logfile then
    local err_msg = string.format("Failed to open conform.nvim log file: %s", openerr)
    vim.notify(err_msg, vim.log.levels.ERROR)
  else
    write = function(line)
      logfile:write(line)
      logfile:write("\n")
      logfile:flush()
    end
  end
end

function Log.log(level, msg, ...)
  if Log.level <= level then
    initialize()
    local text = format(level, msg, ...)
    write(text)
  end
end

function Log.trace(...)
  Log.log(vim.log.levels.TRACE, ...)
end

function Log.debug(...)
  Log.log(vim.log.levels.DEBUG, ...)
end

function Log.info(...)
  Log.log(vim.log.levels.INFO, ...)
end

function Log.warn(...)
  Log.log(vim.log.levels.WARN, ...)
end

function Log.error(...)
  Log.log(vim.log.levels.ERROR, ...)
end

return Log
