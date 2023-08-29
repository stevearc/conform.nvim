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
  local args = {}
  if ctx.range and config.range_args then
    ---@cast ctx conform.RangeContext
    args = config.range_args(ctx)
  elseif config.args then
    if type(config.args) == "function" then
      args = config.args(ctx)
    else
      ---@diagnostic disable-next-line: cast-local-type
      args = config.args
    end
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  for _, v in ipairs(args) do
    if v == "$FILENAME" then
      v = ctx.filename
    elseif v == "$DIRNAME" then
      v = ctx.dirname
    end
    table.insert(cmd, v)
  end
  return cmd
end

---@param range? conform.Range
---@param start_a integer
---@param end_a integer
local function indices_in_range(range, start_a, end_a)
  return not range or (start_a <= range["end"][1] and range["start"][1] <= end_a)
end

---@param a? string
---@param b? string
---@return integer
local function common_prefix_len(a, b)
  if not a or not b then
    return 0
  end
  local min_len = math.min(#a, #b)
  for i = 1, min_len do
    if string.byte(a, i) ~= string.byte(b, i) then
      return i - 1
    end
  end
  return min_len
end

---@param a string
---@param b string
---@return integer
local function common_suffix_len(a, b)
  local a_len = #a
  local b_len = #b
  local min_len = math.min(a_len, b_len)
  for i = 0, min_len - 1 do
    if string.byte(a, a_len - i) ~= string.byte(b, b_len - i) then
      return i
    end
  end
  return min_len
end

local function create_text_edit(
  original_lines,
  replacement,
  is_insert,
  is_replace,
  orig_line_start,
  orig_line_end
)
  local start_line, end_line = orig_line_start - 1, orig_line_end - 1
  local start_char, end_char = 0, 0
  if is_replace then
    -- If we're replacing text, see if we can avoid replacing the entire line
    start_char = common_prefix_len(original_lines[orig_line_start], replacement[1])
    if start_char > 0 then
      replacement[1] = replacement[1]:sub(start_char + 1)
    end

    if original_lines[orig_line_end] then
      local last_line = replacement[#replacement]
      local suffix = common_suffix_len(original_lines[orig_line_end], last_line)
      -- If we're only replacing one line, make sure the prefix/suffix calculations don't overlap
      if orig_line_end == orig_line_start then
        suffix = math.min(suffix, original_lines[orig_line_end]:len() - start_char)
      end
      end_char = original_lines[orig_line_end]:len() - suffix
      if suffix > 0 then
        replacement[#replacement] = last_line:sub(1, last_line:len() - suffix)
      end
    end
  end
  -- If we're inserting text, make sure the text includes a newline at the end.
  -- The one exception is if we're inserting at the end of the file, in which case the newline is
  -- implicit
  if is_insert and start_line < #original_lines - 1 then
    table.insert(replacement, "")
  end
  local new_text = table.concat(replacement, "\n")

  return {
    newText = new_text,
    range = {
      start = {
        line = start_line,
        character = start_char,
      },
      ["end"] = {
        line = end_line,
        character = end_char,
      },
    },
  }
end

---@param bufnr integer
---@param original_lines string[]
---@param new_lines string[]
---@param range? conform.Range
---@param only_apply_range boolean
M.apply_format = function(bufnr, original_lines, new_lines, range, only_apply_range)
  -- If the formatter output didn't have a trailing newline, add one
  if new_lines[#new_lines] ~= "" then
    table.insert(new_lines, "")
  end

  -- Vim buffers end with an implicit newline, so append an empty line to stand in for that
  if vim.bo[bufnr].eol then
    table.insert(original_lines, "")
  end
  local original_text = table.concat(original_lines, "\n")
  local new_text = table.concat(new_lines, "\n")
  local indices = vim.diff(original_text, new_text, {
    result_type = "indices",
    algorithm = "histogram",
  })
  assert(indices)
  local text_edits = {}
  for _, idx in ipairs(indices) do
    local orig_line_start, orig_line_count, new_line_start, new_line_count = unpack(idx)
    local is_insert = orig_line_count == 0
    local is_delete = new_line_count == 0
    local is_replace = not is_insert and not is_delete
    local orig_line_end = orig_line_start + orig_line_count
    local new_line_end = new_line_start + new_line_count

    if is_insert then
      -- When the diff is an insert, it actually means to insert after the mentioned line
      orig_line_start = orig_line_start + 1
      orig_line_end = orig_line_end + 1
    end

    local replacement = util.tbl_slice(new_lines, new_line_start, new_line_end - 1)

    -- For replacement edits, convert the end line to be inclusive
    if is_replace then
      orig_line_end = orig_line_end - 1
    end
    if not only_apply_range or indices_in_range(range, orig_line_start, orig_line_end) then
      local text_edit = create_text_edit(
        original_lines,
        replacement,
        is_insert,
        is_replace,
        orig_line_start,
        orig_line_end
      )
      table.insert(text_edits, text_edit)
    end
  end

  vim.lsp.util.apply_text_edits(text_edits, bufnr, "utf-8")
end

local last_run_errored = {}

---@param bufnr integer
---@param formatter conform.FormatterInfo
---@param config conform.FormatterConfig
---@param ctx conform.Context
---@param quiet boolean
---@param input_lines string[]
---@param callback fun(err?: string, output?: string[])
---@return integer job_id
local function run_formatter(bufnr, formatter, config, ctx, quiet, input_lines, callback)
  local cmd = M.build_cmd(ctx, config)
  local cwd = nil
  if config.cwd then
    cwd = config.cwd(ctx)
  end
  local env = config.env
  if type(env) == "function" then
    env = env(ctx)
  end
  callback = util.wrap_callback(callback, function(err)
    if err then
      if
        not last_run_errored[formatter.name]
        and not quiet
        and require("conform").notify_on_error
      then
        vim.notify(
          string.format("Formatter '%s' failed. See :ConformInfo for details", formatter.name),
          vim.log.levels.ERROR
        )
      end
      last_run_errored[formatter.name] = true
    else
      last_run_errored[formatter.name] = false
    end
  end)

  log.info("Run %s on %s", formatter.name, vim.api.nvim_buf_get_name(bufnr))
  local buffer_text
  -- If the buffer has a newline at the end, make sure we include that in the input to the formatter
  if vim.bo[bufnr].eol then
    table.insert(input_lines, "")
    buffer_text = table.concat(input_lines, "\n")
    table.remove(input_lines)
  else
    buffer_text = table.concat(input_lines, "\n")
  end

  if not config.stdin then
    log.debug("Creating temp file %s", ctx.filename)
    local fd = assert(uv.fs_open(ctx.filename, "w", 448)) -- 0700
    uv.fs_write(fd, buffer_text)
    uv.fs_close(fd)
    callback = util.wrap_callback(callback, function()
      log.debug("Cleaning up temp file %s", ctx.filename)
      uv.fs_unlink(ctx.filename)
    end)
  end

  log.debug("Run command: %s", cmd)
  if cwd then
    log.debug("Run CWD: %s", cwd)
  end
  if env then
    log.debug("Run ENV: %s", env)
  end
  local stdout
  local stderr
  local exit_codes = config.exit_codes or { 0 }
  local jid = vim.fn.jobstart(cmd, {
    cwd = cwd,
    env = env,
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
        log.debug("%s exited with code %d", formatter.name, code)
        callback(nil, output)
      else
        log.info("%s exited with code %d", formatter.name, code)
        log.debug("%s stdout: %s", formatter.name, stdout)
        log.debug("%s stderr: %s", formatter.name, stderr)
        local err_str
        if stderr and not vim.tbl_isempty(stderr) then
          err_str = table.concat(stderr, "\n")
        elseif stdout and not vim.tbl_isempty(stdout) then
          err_str = table.concat(stdout, "\n")
        end
        callback(string.format("Formatter '%s' error: %s", formatter.name, err_str))
      end
    end,
  })
  if jid == 0 then
    callback(string.format("Formatter '%s' invalid arguments", formatter.name))
  elseif jid == -1 then
    callback(string.format("Formatter '%s' command is not executable", formatter.name))
  elseif config.stdin then
    vim.api.nvim_chan_send(jid, buffer_text)
    vim.fn.chanclose(jid, "stdin")
  end
  vim.b[bufnr].conform_jid = jid

  return jid
end

---@param bufnr integer
---@param config conform.FormatterConfig
---@param range? conform.Range
---@return conform.Context
M.build_context = function(bufnr, config, range)
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
    range = range,
  }
end

---@param bufnr integer
---@param formatters conform.FormatterInfo[]
---@param quiet boolean
---@param range? conform.Range
---@param callback? fun(err?: string)
M.format_async = function(bufnr, formatters, quiet, range, callback)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local idx = 1
  local changedtick = vim.b[bufnr].changedtick
  local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input_lines = original_lines
  local all_support_range_formatting = true

  -- kill previous jobs for buffer
  local prev_jid = vim.b[bufnr].conform_jid
  if prev_jid then
    if vim.fn.jobstop(prev_jid) == 1 then
      log.info("Canceled previous format job for %s", vim.api.nvim_buf_get_name(bufnr))
    end
  end

  local function run_next_formatter()
    local formatter = formatters[idx]
    if not formatter then
      -- discard formatting if buffer has changed
      if vim.b[bufnr].changedtick == changedtick then
        M.apply_format(bufnr, original_lines, input_lines, range, not all_support_range_formatting)
      else
        log.info(
          "Async formatter discarding changes for %s: concurrent modification",
          vim.api.nvim_buf_get_name(bufnr)
        )
      end
      if callback then
        callback()
      end
      return
    end
    idx = idx + 1

    local config = assert(require("conform").get_formatter_config(formatter.name, bufnr))
    local ctx = M.build_context(bufnr, config, range)
    local jid
    jid = run_formatter(bufnr, formatter, config, ctx, quiet, input_lines, function(err, output)
      if err then
        -- Only log the error if the job wasn't canceled
        if vim.api.nvim_buf_is_valid(bufnr) and jid == vim.b[bufnr].conform_jid then
          log.error(err)
        end
        if callback then
          callback(err)
        end
        return
      end
      input_lines = output
      run_next_formatter()
    end)
    all_support_range_formatting = all_support_range_formatting and config.range_args ~= nil
  end
  run_next_formatter()
end

---@param bufnr integer
---@param formatters conform.FormatterInfo[]
---@param timeout_ms integer
---@param quiet boolean
---@param range? conform.Range
M.format_sync = function(bufnr, formatters, timeout_ms, quiet, range)
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
      log.info("Canceled previous format job for %s", vim.api.nvim_buf_get_name(bufnr))
    end
  end

  local all_support_range_formatting = true
  for _, formatter in ipairs(formatters) do
    local remaining = timeout_ms - (uv.hrtime() / 1e6 - start)
    if remaining <= 0 then
      if quiet then
        log.warn("Formatter '%s' timed out", formatter.name)
      else
        vim.notify(string.format("Formatter '%s' timed out", formatter.name), vim.log.levels.WARN)
      end
      return
    end
    local done = false
    local result = nil
    local config = assert(require("conform").get_formatter_config(formatter.name, bufnr))
    local ctx = M.build_context(bufnr, config, range)
    local jid = run_formatter(
      bufnr,
      formatter,
      config,
      ctx,
      quiet,
      input_lines,
      function(err, output)
        if err then
          log.error(err)
        end
        done = true
        result = output
      end
    )
    all_support_range_formatting = all_support_range_formatting and config.range_args ~= nil

    local wait_result, wait_reason = vim.wait(remaining, function()
      return done
    end, 5)

    if not wait_result then
      if wait_reason == -1 then
        if quiet then
          log.warn("Formatter '%s' timed out", formatter.name)
        else
          vim.notify(string.format("Formatter '%s' timed out", formatter.name), vim.log.levels.WARN)
        end
      end
      vim.fn.jobstop(jid)
      return
    end

    if not result then
      return
    end

    input_lines = result
  end

  local final_result = input_lines
  M.apply_format(bufnr, original_lines, final_result, range, not all_support_range_formatting)
end

return M
