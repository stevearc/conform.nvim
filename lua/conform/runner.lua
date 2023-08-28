local fs = require("conform.fs")
local log = require("conform.log")
local util = require("conform.util")
local uv = vim.uv or vim.loop
local M = {}

---@param ctx conform.Context
---@param config conform.FormatterConfig
M.build_cmd = function(ctx, config)
  local command = config.command
  if type(command) == "function" then
    command = command(ctx)
  end
  local cmd = { command }
  if config.args then
    local args = config.args
    if type(config.args) == "function" then
      args = config.args(ctx)
    end
    ---@cast args string[]
    for _, v in ipairs(args) do
      if v == "$FILENAME" then
        v = ctx.filename
      elseif v == "$DIRNAME" then
        v = ctx.dirname
      end
      table.insert(cmd, v)
    end
  end
  return cmd
end

---@param bufnr integer
---@param original_lines string[]
---@param new_lines string[]
local function apply_format(bufnr, original_lines, new_lines)
  local original_text = table.concat(original_lines, "\n")
  -- Trim off the final newline from the formatted text because that is baked in to
  -- the vim lines representation
  if new_lines[#new_lines] == "" then
    new_lines[#new_lines] = nil
  end
  local new_text = table.concat(new_lines, "\n")
  local indices = vim.diff(original_text, new_text, {
    result_type = "indices",
    algorithm = "histogram",
  })
  assert(indices)
  for i = #indices, 1, -1 do
    local start_a, count_a, start_b, count_b = unpack(indices[i])
    -- When count_a is 0, the diff is an insert after the line
    if count_a == 0 then
      -- This happens when the first line is blank and we're inserting text after it
      if start_a == 0 then
        count_a = 1
      end
      start_a = start_a + 1
    end

    -- If this diff range goes *up to* the last line in the original file, *and* the last line
    -- after that is just an empty space, then the diff range here was calculated to include that
    -- final newline, so we should bump up the count_a to include it
    if (start_a + count_a) == #original_lines and original_lines[#original_lines] == "" then
      count_a = count_a + 1
    end
    -- Same logic for the new lines
    if (start_b + count_b) == #new_lines and new_lines[#new_lines] == "" then
      count_b = count_b + 1
    end
    local replacement = util.tbl_slice(new_lines, start_b, start_b + count_b - 1)
    vim.api.nvim_buf_set_lines(bufnr, start_a - 1, start_a - 1 + count_a, true, replacement)
  end
end

---@param bufnr integer
---@param formatter conform.FormatterInfo
---@param input_lines string[]
---@param callback fun(err?: string, output?: string[])
---@return integer
local function run_formatter(bufnr, formatter, input_lines, callback)
  local config = assert(require("conform").get_formatter_config(formatter.name))
  local ctx = M.build_context(bufnr, config)
  local cmd = M.build_cmd(ctx, config)
  local cwd = nil
  if config.cwd then
    cwd = config.cwd(ctx)
  end
  log.info("Running formatter %s on buffer %d", formatter.name, bufnr)
  if not config.stdin then
    log.debug("Creating temp file %s", ctx.filename)
    local fd = assert(uv.fs_open(ctx.filename, "w", 448)) -- 0700
    uv.fs_write(fd, table.concat(input_lines, "\n"))
    uv.fs_close(fd)
    local final_cb = callback
    callback = function(...)
      log.debug("Cleaning up temp file %s", ctx.filename)
      uv.fs_unlink(ctx.filename)
      final_cb(...)
    end
  end
  log.debug("Running command: %s", cmd)
  if cwd then
    log.debug("Running in CWD: %s", cwd)
  end
  local stdout
  local stderr
  local exit_codes = config.exit_codes or { 0 }
  local jid = vim.fn.jobstart(cmd, {
    cwd = cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    stdin = config.stdin and "pipe" or "null",
    on_stdout = function(_, data)
      if config.stdin then
        stdout = data
      end
    end,
    on_stderr = function(_, data)
      stderr = data
    end,
    on_exit = function(_, code)
      local output
      if not config.stdin then
        local fd = assert(uv.fs_open(ctx.filename, "r", 448)) -- 0700
        local stat = assert(uv.fs_fstat(fd))
        local content = assert(uv.fs_read(fd, stat.size))
        uv.fs_close(fd)
        output = vim.split(content, "\n", { plain = true })
      else
        output = stdout
      end
      if vim.tbl_contains(exit_codes, code) then
        log.debug("Formatter %s exited with code %d", formatter.name, code)
        callback(nil, output)
      else
        log.error("Formatter %s exited with code %d", formatter.name, code)
        log.warn("Formatter %s stdout:", formatter.name, stdout)
        log.warn("Formatter %s stderr:", formatter.name, stderr)
        local stderr_str
        if stderr then
          stderr_str = table.concat(stderr, "\n")
        end
        callback(string.format("Formatter '%s' error: %s", formatter.name, stderr_str))
      end
    end,
  })
  if jid == 0 then
    callback(string.format("Formatter '%s' invalid arguments", formatter.name))
  elseif jid == -1 then
    callback(string.format("Formatter '%s' command is not executable", formatter.name))
  elseif config.stdin then
    local text = table.concat(input_lines, "\n")
    vim.api.nvim_chan_send(jid, text)
    vim.fn.chanclose(jid, "stdin")
  end
  vim.b[bufnr].conform_jid = jid

  return jid
end

---@param bufnr integer
---@param config conform.FormatterConfig
---@return conform.Context
M.build_context = function(bufnr, config)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local filename = vim.api.nvim_buf_get_name(bufnr)

  -- Hack around checkhealth. For buffers that are not files, we need to fabricate a filename
  if vim.bo[bufnr].buftype ~= "" then
    filename = ""
  end
  local dirname
  if filename == "" then
    dirname = vim.fn.getcwd()
    filename = fs.join(dirname, "unnamed_temp")
    local ft = vim.bo[bufnr].filetype
    if ft and ft ~= "" then
      filename = filename .. "." .. ft
    end
  else
    dirname = vim.fs.dirname(filename)
  end

  if not config.stdin then
    local basename = vim.fs.basename(filename)
    local tmpname = string.format(".conform.%d.%s", math.random(1000000, 9999999), basename)
    local parent = vim.fs.dirname(filename)
    filename = fs.join(parent, tmpname)
  end
  return {
    buf = bufnr,
    filename = filename,
    dirname = dirname,
  }
end

---@param bufnr integer
---@param formatters conform.FormatterInfo[]
---@param callback? fun(err?: string)
M.format_async = function(bufnr, formatters, callback)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local idx = 1
  local changedtick = vim.b[bufnr].changedtick
  local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input_lines = original_lines

  -- kill previous jobs for buffer
  local prev_jid = vim.b[bufnr].conform_jid
  if prev_jid then
    if vim.fn.jobstop(prev_jid) == 1 then
      log.info("Canceled previous format job for buffer %d", bufnr)
    end
  end

  local function run_next_formatter()
    local formatter = formatters[idx]
    if not formatter then
      -- discard formatting if buffer has changed
      if vim.b[bufnr].changedtick == changedtick then
        apply_format(bufnr, original_lines, input_lines)
      else
        log.warn("Async formatter discarding changes for buffer %d: concurrent modification", bufnr)
      end
      if callback then
        callback()
      end
      return
    end
    idx = idx + 1

    local jid
    jid = run_formatter(bufnr, formatter, input_lines, function(err, output)
      if err then
        -- Only display the error if the job wasn't canceled
        if vim.api.nvim_buf_is_valid(bufnr) and jid == vim.b[bufnr].conform_jid then
          vim.notify(err, vim.log.levels.ERROR)
        end
        if callback then
          callback(err)
        end
        return
      end
      input_lines = output
      run_next_formatter()
    end)
  end
  run_next_formatter()
end

---@param bufnr integer
---@param formatters conform.FormatterInfo[]
---@param timeout_ms integer
M.format_sync = function(bufnr, formatters, timeout_ms)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local start = uv.hrtime() / 1e6
  local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input_lines = original_lines

  -- kill previous jobs for buffer
  local prev_jid = vim.b[bufnr].conform_jid
  if prev_jid then
    if vim.fn.jobstop(prev_jid) == 1 then
      log.info("Canceled previous format job for buffer %d", bufnr)
    end
  end

  for _, formatter in ipairs(formatters) do
    local remaining = timeout_ms - (uv.hrtime() / 1e6 - start)
    if remaining <= 0 then
      vim.notify(string.format("Formatter '%s' timed out", formatter.name), vim.log.levels.WARN)
      return
    end
    local done = false
    local result = nil
    run_formatter(bufnr, formatter, input_lines, function(err, output)
      if err then
        vim.notify(err, vim.log.levels.ERROR)
      end
      done = true
      result = output
    end)

    local wait_result, wait_reason = vim.wait(remaining, function()
      return done
    end, 5)

    if not wait_result then
      if wait_reason == -1 then
        vim.notify(string.format("Formatter '%s' timed out", formatter.name), vim.log.levels.WARN)
      end
      return
    end

    if not result then
      return
    end

    input_lines = result
  end

  local final_result = input_lines
  apply_format(bufnr, original_lines, final_result)
end

return M
