local errors = require("conform.errors")
local fs = require("conform.fs")
local log = require("conform.log")
local lsp_format = require("conform.lsp_format")
local util = require("conform.util")
local uv = vim.uv or vim.loop
local M = {}

---@class (exact) conform.RunOpts
---@field exclusive boolean If true, ensure only a single formatter is running per buffer
---@field dry_run boolean If true, do not apply changes and stop after the first formatter attempts to do so

---@param formatter_name string
---@param ctx conform.Context
---@param config conform.JobFormatterConfig
---@return string|string[]
M.build_cmd = function(formatter_name, ctx, config)
  local command = config.command
  if type(command) == "function" then
    command = util.compat_call_with_self(formatter_name, config, command, ctx)
  end
  ---@type string|string[]
  local args = {}
  if ctx.range and config.range_args then
    args = util.compat_call_with_self(formatter_name, config, config.range_args, ctx)
  elseif config.args then
    local computed_args = config.args
    if type(computed_args) == "function" then
      args = util.compat_call_with_self(formatter_name, config, computed_args, ctx)
    else
      ---@diagnostic disable-next-line: cast-local-type
      args = computed_args
    end
  end

  if type(args) == "string" then
    local interpolated = args:gsub("$FILENAME", ctx.filename):gsub("$DIRNAME", ctx.dirname)
    return command .. " " .. interpolated
  else
    local cmd = { command }
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
end

---@param value any
---@return boolean
local function truthy(value)
  return value ~= nil and value ~= false
end

---@param bufnr integer
---@param original_lines string[]
---@param new_lines string[]
---@param range? conform.Range
---@param only_apply_range boolean
---@return boolean any_changes
M.apply_format = function(bufnr, original_lines, new_lines, range, only_apply_range, dry_run)
  local text_edits =
    lsp_format.as_text_edits(bufnr, original_lines, new_lines, range, only_apply_range)
  if not text_edits then
    return false
  end

  if not dry_run then
    log.trace("Applying text edits: %s", text_edits)
    vim.lsp.util.apply_text_edits(text_edits, bufnr, "utf-8")
    log.trace("Done formatting %s", vim.api.nvim_buf_get_name(bufnr))
  end

  return not vim.tbl_isempty(text_edits)
end

---Map of formatter name to if the last run of that formatter produced an error
---@type table<string, boolean>
local last_run_errored = {}

---@param bufnr integer
---@param formatter conform.FormatterInfo
---@param config conform.FormatterConfig
---@param ctx conform.Context
---@param input_lines string[]
---@param opts conform.RunOpts
---@param callback fun(err?: conform.Error, output?: string[])
---@return integer? job_id
local function run_formatter(bufnr, formatter, config, ctx, input_lines, opts, callback)
  log.info("Run %s on %s", formatter.name, vim.api.nvim_buf_get_name(bufnr))
  log.trace("Input lines: %s", input_lines)
  callback = util.wrap_callback(callback, function(err)
    if err then
      if last_run_errored[formatter.name] then
        err.debounce_message = true
      end
      last_run_errored[formatter.name] = true
    else
      last_run_errored[formatter.name] = false
    end
  end)
  if config.format then
    ---@cast config conform.LuaFormatterConfig
    local ok, err = pcall(config.format, config, ctx, input_lines, callback)
    if not ok then
      callback({
        code = errors.ERROR_CODE.RUNTIME,
        message = string.format("Formatter '%s' error: %s", formatter.name, err),
      })
    end
    return
  end
  ---@cast config conform.JobFormatterConfig
  local cmd = M.build_cmd(formatter.name, ctx, config)
  local cwd = nil
  if config.cwd then
    cwd = util.compat_call_with_self(formatter.name, config, config.cwd, ctx)
  end
  local env = config.env
  if type(env) == "function" then
    env = util.compat_call_with_self(formatter.name, config, env, ctx)
  end

  local buffer_text
  -- If the buffer has a newline at the end, make sure we include that in the input to the formatter
  local add_extra_newline = vim.bo[bufnr].eol
  if add_extra_newline then
    table.insert(input_lines, "")
  end
  buffer_text = table.concat(input_lines, "\n")
  if add_extra_newline then
    table.remove(input_lines)
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
  local jid
  local ok, jid_or_err = pcall(vim.fn.jobstart, cmd, {
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
      if vim.tbl_contains(exit_codes, code) then
        local output
        if not config.stdin then
          local fd = assert(uv.fs_open(ctx.filename, "r", 448)) -- 0700
          local stat = assert(uv.fs_fstat(fd))
          local content = assert(uv.fs_read(fd, stat.size))
          uv.fs_close(fd)
          output = vim.split(content, "\r?\n", {})
        else
          output = stdout
        end
        -- Remove the trailing newline from the output to convert back to vim lines representation
        if add_extra_newline and output[#output] == "" then
          table.remove(output)
        end
        -- Vim will never let the lines array be empty. An empty file will still look like { "" }
        if #output == 0 then
          table.insert(output, "")
        end
        log.debug("%s exited with code %d", formatter.name, code)
        log.trace("Output lines: %s", output)
        log.trace("%s stderr: %s", formatter.name, stderr)
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
        if
          vim.api.nvim_buf_is_valid(bufnr)
          and jid ~= vim.b[bufnr].conform_jid
          and opts.exclusive
        then
          callback({
            code = errors.ERROR_CODE.INTERRUPTED,
            message = string.format("Formatter '%s' was interrupted", formatter.name),
          })
        else
          callback({
            code = errors.ERROR_CODE.RUNTIME,
            message = string.format("Formatter '%s' error: %s", formatter.name, err_str),
          })
        end
      end
    end,
  })
  if not ok then
    callback({
      code = errors.ERROR_CODE.JOBSTART,
      message = string.format("Formatter '%s' error in jobstart: %s", formatter.name, jid_or_err),
    })
    return
  end
  jid = jid_or_err
  if jid == 0 then
    callback({
      code = errors.ERROR_CODE.INVALID_ARGS,
      message = string.format("Formatter '%s' invalid arguments", formatter.name),
    })
  elseif jid == -1 then
    callback({
      code = errors.ERROR_CODE.NOT_EXECUTABLE,
      message = string.format("Formatter '%s' command is not executable", formatter.name),
    })
  elseif config.stdin then
    vim.api.nvim_chan_send(jid, buffer_text)
    vim.fn.chanclose(jid, "stdin")
  end
  if opts.exclusive then
    vim.b[bufnr].conform_jid = jid
  end

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
---@param range? conform.Range
---@param opts conform.RunOpts
---@param callback fun(err?: conform.Error, did_edit?: boolean)
M.format_async = function(bufnr, formatters, range, opts, callback)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  -- kill previous jobs for buffer
  local prev_jid = vim.b[bufnr].conform_jid
  if prev_jid and opts.exclusive then
    if vim.fn.jobstop(prev_jid) == 1 then
      log.info("Canceled previous format job for %s", vim.api.nvim_buf_get_name(bufnr))
    end
  end

  local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local changedtick = vim.b[bufnr].changedtick
  M.format_lines_async(
    bufnr,
    formatters,
    range,
    original_lines,
    opts,
    function(err, output_lines, all_support_range_formatting)
      local did_edit = nil
      -- discard formatting if buffer has changed
      if not vim.api.nvim_buf_is_valid(bufnr) or changedtick ~= util.buf_get_changedtick(bufnr) then
        err = {
          code = errors.ERROR_CODE.CONCURRENT_MODIFICATION,
          message = string.format(
            "Async formatter discarding changes for %d: concurrent modification",
            bufnr
          ),
        }
      else
        did_edit = M.apply_format(
          bufnr,
          original_lines,
          output_lines,
          range,
          not all_support_range_formatting,
          opts.dry_run
        )
      end
      callback(err, did_edit)
    end
  )
end

---@param bufnr integer
---@param formatters conform.FormatterInfo[]
---@param range? conform.Range
---@param input_lines string[]
---@param opts conform.RunOpts
---@param callback fun(err?: conform.Error, output_lines: string[], all_support_range_formatting: boolean)
M.format_lines_async = function(bufnr, formatters, range, input_lines, opts, callback)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local idx = 1
  local all_support_range_formatting = true
  local final_err = nil

  local function run_next_formatter()
    local formatter = formatters[idx]
    if not formatter then
      callback(final_err, input_lines, all_support_range_formatting)
      return
    end
    idx = idx + 1

    local config = assert(require("conform").get_formatter_config(formatter.name, bufnr))
    local ctx = M.build_context(bufnr, config, range)
    run_formatter(bufnr, formatter, config, ctx, input_lines, opts, function(err, output)
      if err then
        final_err = errors.coalesce(final_err, err)
      end
      input_lines = output or input_lines
      all_support_range_formatting = all_support_range_formatting and truthy(config.range_args)
      run_next_formatter()
    end)
  end
  run_next_formatter()
end

---@param bufnr integer
---@param formatters conform.FormatterInfo[]
---@param timeout_ms integer
---@param range? conform.Range
---@param opts conform.RunOpts
---@return conform.Error? error
---@return boolean did_edit
M.format_sync = function(bufnr, formatters, timeout_ms, range, opts)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- kill previous jobs for buffer
  local prev_jid = vim.b[bufnr].conform_jid
  if prev_jid and opts.exclusive then
    if vim.fn.jobstop(prev_jid) == 1 then
      log.info("Canceled previous format job for %s", vim.api.nvim_buf_get_name(bufnr))
    end
  end

  local err, final_result, all_support_range_formatting =
    M.format_lines_sync(bufnr, formatters, timeout_ms, range, original_lines, opts)

  local did_edit = M.apply_format(
    bufnr,
    original_lines,
    final_result,
    range,
    not all_support_range_formatting,
    opts.dry_run
  )
  return err, did_edit
end

---@param bufnr integer
---@param formatters conform.FormatterInfo[]
---@param timeout_ms integer
---@param range? conform.Range
---@param opts conform.RunOpts
---@return conform.Error? error
---@return string[] output_lines
---@return boolean all_support_range_formatting
M.format_lines_sync = function(bufnr, formatters, timeout_ms, range, input_lines, opts)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local start = uv.hrtime() / 1e6

  local all_support_range_formatting = true
  local final_err = nil
  for _, formatter in ipairs(formatters) do
    local remaining = timeout_ms - (uv.hrtime() / 1e6 - start)
    if remaining <= 0 then
      return errors.coalesce(final_err, {
        code = errors.ERROR_CODE.TIMEOUT,
        message = string.format("Formatter '%s' timeout", formatter.name),
      }),
        input_lines,
        all_support_range_formatting
    end
    local done = false
    local result = nil
    ---@type conform.FormatterConfig
    local config = assert(require("conform").get_formatter_config(formatter.name, bufnr))
    local ctx = M.build_context(bufnr, config, range)
    local jid = run_formatter(
      bufnr,
      formatter,
      config,
      ctx,
      input_lines,
      opts,
      function(err, output)
        final_err = errors.coalesce(final_err, err)
        done = true
        result = output
      end
    )
    all_support_range_formatting = all_support_range_formatting and truthy(config.range_args)

    local wait_result, wait_reason = vim.wait(remaining, function()
      return done
    end, 5)

    if not wait_result then
      if jid then
        vim.fn.jobstop(jid)
      end
      if wait_reason == -1 then
        return errors.coalesce(final_err, {
          code = errors.ERROR_CODE.TIMEOUT,
          message = string.format("Formatter '%s' timeout", formatter.name),
        }),
          input_lines,
          all_support_range_formatting
      else
        return errors.coalesce(final_err, {
          code = errors.ERROR_CODE.INTERRUPTED,
          message = string.format("Formatter '%s' was interrupted", formatter.name),
        }),
          input_lines,
          all_support_range_formatting
      end
    end

    input_lines = result or input_lines
  end

  return final_err, input_lines, all_support_range_formatting
end

return M
