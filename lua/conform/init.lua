local M = {}

---@type table<string, conform.FiletypeFormatter>
M.formatters_by_ft = {}

---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
M.formatters = {}

M.notify_on_error = true
M.notify_no_formatters = true

---@type conform.DefaultFormatOpts
M.default_format_opts = {}

-- Defer notifications because nvim-notify can throw errors if called immediately
-- in some contexts (e.g. inside statusline function)
local notify = vim.schedule_wrap(function(...)
  vim.notify(...)
end)
local notify_once = vim.schedule_wrap(function(...)
  vim.notify_once(...)
end)

local allowed_default_opts = { "timeout_ms", "lsp_format", "quiet", "stop_after_first" }
local allowed_default_filetype_opts = { "name", "id", "filter" }
---@param a table
---@param b table
---@param opts? { allow_filetype_opts?: boolean }
---@return table
local function merge_default_opts(a, b, opts)
  for _, key in ipairs(allowed_default_opts) do
    if a[key] == nil then
      a[key] = b[key]
    end
  end
  if opts and opts.allow_filetype_opts then
    for _, key in ipairs(allowed_default_filetype_opts) do
      if a[key] == nil then
        a[key] = b[key]
      end
    end
  end
  return a
end

---@param conf? conform.FiletypeFormatter
local function check_for_default_opts(conf)
  if not conf or type(conf) ~= "table" then
    return
  end
  for k in pairs(conf) do
    if type(k) == "string" then
      notify(
        string.format(
          'conform.setup: the "*" key in formatters_by_ft does not support configuring format options, such as "%s"',
          k
        ),
        vim.log.levels.WARN
      )
      break
    end
  end
end

---@param opts? conform.setupOpts
M.setup = function(opts)
  if vim.fn.has("nvim-0.10") == 0 then
    notify("conform.nvim requires Neovim 0.10+", vim.log.levels.ERROR)
    return
  end
  opts = opts or {}

  M.formatters = vim.tbl_extend("force", M.formatters, opts.formatters or {})
  M.formatters_by_ft = vim.tbl_extend("force", M.formatters_by_ft, opts.formatters_by_ft or {})
  check_for_default_opts(M.formatters_by_ft["*"])
  M.default_format_opts =
    vim.tbl_extend("force", M.default_format_opts, opts.default_format_opts or {})

  if opts.log_level then
    require("conform.log").level = opts.log_level
  end
  if opts.notify_on_error ~= nil then
    M.notify_on_error = opts.notify_on_error
  end
  if opts.notify_no_formatters ~= nil then
    M.notify_no_formatters = opts.notify_no_formatters
  end

  local aug = vim.api.nvim_create_augroup("Conform", { clear = true })
  if opts.format_on_save then
    if type(opts.format_on_save) == "boolean" then
      opts.format_on_save = {}
    end
    vim.api.nvim_create_autocmd("BufWritePre", {
      desc = "Format on save",
      pattern = "*",
      group = aug,
      callback = function(args)
        if not vim.api.nvim_buf_is_valid(args.buf) or vim.bo[args.buf].buftype ~= "" then
          return
        end
        local format_args, callback = opts.format_on_save, nil
        if type(format_args) == "function" then
          format_args, callback = format_args(args.buf)
        end
        if format_args then
          if format_args.async then
            notify_once(
              "Conform format_on_save cannot use async=true. Use format_after_save instead.",
              vim.log.levels.ERROR
            )
          end
          M.format(
            vim.tbl_deep_extend("force", format_args, {
              buf = args.buf,
              async = false,
            }),
            callback
          )
        end
      end,
    })
    vim.api.nvim_create_autocmd("VimLeavePre", {
      desc = "conform.nvim hack to work around Neovim bug",
      pattern = "*",
      group = aug,
      callback = function()
        -- HACK: Work around https://github.com/neovim/neovim/issues/21856
        -- causing exit code 134 on :wq
        vim.cmd.sleep({ args = { "1m" } })
      end,
    })
  end

  if opts.format_after_save then
    if type(opts.format_after_save) == "boolean" then
      opts.format_after_save = {}
    end
    local exit_timeout = 1000
    local num_running_format_jobs = 0
    vim.api.nvim_create_autocmd("BufWritePost", {
      desc = "Format after save",
      pattern = "*",
      group = aug,
      callback = function(args)
        if
          not vim.api.nvim_buf_is_valid(args.buf)
          or vim.b[args.buf].conform_applying_formatting
          or vim.bo[args.buf].buftype ~= ""
        then
          return
        end
        local format_args, callback = opts.format_after_save, nil
        if type(format_args) == "function" then
          format_args, callback = format_args(args.buf)
        end
        if format_args then
          exit_timeout = format_args.timeout_ms or exit_timeout
          num_running_format_jobs = num_running_format_jobs + 1
          if format_args.async == false then
            notify_once(
              "Conform format_after_save cannot use async=false. Use format_on_save instead.",
              vim.log.levels.ERROR
            )
          end
          M.format(
            vim.tbl_deep_extend("force", format_args, {
              buf = args.buf,
              async = true,
            }),
            function(err)
              num_running_format_jobs = num_running_format_jobs - 1
              if not err and vim.api.nvim_buf_is_valid(args.buf) then
                vim.api.nvim_buf_call(args.buf, function()
                  vim.b[args.buf].conform_applying_formatting = true
                  vim.cmd.update()
                  vim.b[args.buf].conform_applying_formatting = false
                end)
              end
              if callback then
                callback(err)
              end
            end
          )
        end
      end,
    })

    vim.api.nvim_create_autocmd("BufWinLeave", {
      desc = "conform.nvim store changedtick for use during Neovim exit",
      pattern = "*",
      group = aug,
      callback = function(args)
        -- We store this because when vim is exiting it will set changedtick = -1 for visible
        -- buffers right after firing BufWinLeave
        vim.b[args.buf].last_changedtick = vim.api.nvim_buf_get_changedtick(args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
      desc = "conform.nvim wait for running formatters before exit",
      pattern = "*",
      group = aug,
      callback = function()
        if num_running_format_jobs == 0 then
          return
        end
        local uv = vim.uv or vim.loop
        local start = uv.hrtime() / 1e6
        vim.wait(exit_timeout, function()
          return num_running_format_jobs == 0
        end, 10)
        local elapsed = uv.hrtime() / 1e6 - start
        if elapsed > 200 then
          local log = require("conform.log")
          log.warn("Delayed Neovim exit by %dms to wait for formatting to complete", elapsed)
        end
        -- HACK: Work around https://github.com/neovim/neovim/issues/21856
        -- causing exit code 134 on :wq
        vim.cmd.sleep({ args = { "1m" } })
      end,
    })
  end
end

---@param obj any
---@return boolean
local function is_empty_table(obj)
  return type(obj) == "table" and vim.tbl_isempty(obj)
end

---Get the configured formatter filetype for a buffer
---@param bufnr? integer
---@return nil|string filetype or nil if no formatter is configured. Can be "_".
local function get_matching_filetype(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local filetypes = vim.split(vim.bo[bufnr].filetype, ".", { plain = true })
  -- Reverse the list so we can check the most specific filetypes first.
  -- Start with the whole filetype, so users can specify an entire compound filetype if they want.
  -- (e.g. "markdown.vimwiki")
  local rev_filetypes = { vim.bo[bufnr].filetype }
  for i = #filetypes, 1, -1 do
    table.insert(rev_filetypes, filetypes[i])
  end
  table.insert(rev_filetypes, "_")
  for _, filetype in ipairs(rev_filetypes) do
    local ft_formatters = M.formatters_by_ft[filetype]
    -- Sometimes people put an empty table here, and that should not count as configuring formatters
    -- for a filetype.
    if ft_formatters and not is_empty_table(ft_formatters) then
      return filetype
    end
  end
end

---@private
---@param bufnr? integer
---@return string[]
M.list_formatters_for_buffer = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local formatters = {}
  local seen = {}

  local function dedupe_formatters(names, collect)
    for _, name in ipairs(names) do
      assert(
        type(name) == "string",
        "The nested {} syntax to run the first formatter has been replaced by the stop_after_first option (see :help conform.format)."
      )
      if not seen[name] then
        table.insert(collect, name)
        seen[name] = true
      end
    end
  end

  local filetypes = {}
  local matching_filetype = get_matching_filetype(bufnr)
  if matching_filetype then
    table.insert(filetypes, matching_filetype)
  end
  table.insert(filetypes, "*")
  for _, ft in ipairs(filetypes) do
    local ft_formatters = M.formatters_by_ft[ft]
    if ft_formatters then
      if type(ft_formatters) == "function" then
        dedupe_formatters(ft_formatters(bufnr), formatters)
      else
        dedupe_formatters(ft_formatters, formatters)
      end
    end
  end

  return formatters
end

---@param bufnr? integer
---@return nil|conform.DefaultFiletypeFormatOpts
local function get_opts_from_filetype(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local matching_filetype = get_matching_filetype(bufnr)
  if not matching_filetype then
    return nil
  end

  local ft_formatters = M.formatters_by_ft[matching_filetype]
  assert(ft_formatters ~= nil, "get_matching_filetype ensures formatters_by_ft has key")
  if type(ft_formatters) == "function" then
    ft_formatters = ft_formatters(bufnr)
  end
  return merge_default_opts({}, ft_formatters, { allow_filetype_opts = true })
end

---@param bufnr integer
---@param mode "v"|"V"
---@return conform.Range {start={row,col}, end={row,col}} using (1, 0) indexing
local function range_from_selection(bufnr, mode)
  -- [bufnum, lnum, col, off]; both row and column 1-indexed
  local start = vim.fn.getpos("v")
  local end_ = vim.fn.getpos(".")
  local start_row = start[2]
  local start_col = start[3]
  local end_row = end_[2]
  local end_col = end_[3]

  -- A user can start visual selection at the end and move backwards
  -- Normalize the range to start < end
  if start_row == end_row and end_col < start_col then
    end_col, start_col = start_col, end_col
  elseif end_row < start_row then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end
  if mode == "V" then
    start_col = 1
    local lines = vim.api.nvim_buf_get_lines(bufnr, end_row - 1, end_row, true)
    end_col = #lines[1]
  end
  return {
    ["start"] = { start_row, start_col - 1 },
    ["end"] = { end_row, end_col - 1 },
  }
end

---@private
---@param names conform.FiletypeFormatterInternal
---@param bufnr integer
---@param warn_on_missing boolean
---@param stop_after_first boolean
---@return conform.FormatterInfo[]
M.resolve_formatters = function(names, bufnr, warn_on_missing, stop_after_first)
  local all_info = {}
  local function add_info(info, warn)
    if info.available then
      table.insert(all_info, info)
    elseif warn then
      notify(
        string.format("Formatter '%s' unavailable: %s", info.name, info.available_msg),
        vim.log.levels.WARN
      )
    end
    return info.available
  end

  for _, name in ipairs(names) do
    assert(
      type(name) == "string",
      "The nested {} syntax to run the first formatter has been replaced by the stop_after_first option (see :help conform.format)."
    )
    local info = M.get_formatter_info(name, bufnr)
    add_info(info, warn_on_missing)

    if stop_after_first and #all_info > 0 then
      break
    end
  end
  return all_info
end

---@param opts table
---@return boolean
local function has_lsp_formatter(opts)
  local lsp_format = require("conform.lsp_format")
  return not vim.tbl_isempty(lsp_format.get_format_clients(opts))
end

local has_notified_ft_no_formatters = {}

---Format a buffer
---@param opts? conform.FormatOpts
---@param callback? fun(err: nil|string, did_edit: nil|boolean) Called once formatting has completed
---@return boolean True if any formatters were attempted
---@example
--- -- Synchronously format the current buffer
--- conform.format({ lsp_format = "fallback" })
--- -- Asynchronously format the current buffer; will not block the UI
--- conform.format({ async = true }, function(err, did_edit)
---   -- called after formatting
--- end
--- -- Format the current buffer with a specific formatter
--- conform.format({ formatters = { "ruff_fix" } })
M.format = function(opts, callback)
  if vim.fn.has("nvim-0.10") == 0 then
    notify_once("conform.nvim requires Neovim 0.10+", vim.log.levels.ERROR)
    if callback then
      callback("conform.nvim requires Neovim 0.10+")
    end
    return false
  end
  opts = opts or {}
  local has_explicit_formatters = opts.formatters ~= nil
  -- If formatters were not passed in directly, fetch any options from formatters_by_ft
  if not has_explicit_formatters then
    merge_default_opts(
      opts,
      get_opts_from_filetype(opts.bufnr) or {},
      { allow_filetype_opts = true }
    )
  end
  merge_default_opts(opts, M.default_format_opts)
  ---@type {timeout_ms: integer, bufnr: integer, async: boolean, dry_run: boolean, lsp_format: "never"|"first"|"last"|"prefer"|"fallback", quiet: boolean, stop_after_first: boolean, formatters?: string[], range?: conform.Range, undojoin: boolean}
  opts = vim.tbl_extend("keep", opts, {
    timeout_ms = 1000,
    bufnr = 0,
    async = false,
    dry_run = false,
    lsp_format = "never",
    quiet = false,
    undojoin = false,
    stop_after_first = false,
  })
  if opts.bufnr == 0 then
    opts.bufnr = vim.api.nvim_get_current_buf()
  end

  -- For backwards compatibility
  ---@diagnostic disable-next-line: undefined-field
  if opts.lsp_fallback == true then
    opts.lsp_format = "fallback"
    ---@diagnostic disable-next-line: undefined-field
  elseif opts.lsp_fallback == "always" then
    opts.lsp_format = "last"
  end

  local mode = vim.api.nvim_get_mode().mode
  if not opts.range and mode == "v" or mode == "V" then
    opts.range = range_from_selection(opts.bufnr, mode)
  end
  callback = callback or function(_err, _did_edit) end
  local errors = require("conform.errors")
  local log = require("conform.log")
  local lsp_format = require("conform.lsp_format")
  local runner = require("conform.runner")

  local formatter_names = opts.formatters or M.list_formatters_for_buffer(opts.bufnr)
  local formatters = M.resolve_formatters(
    formatter_names,
    opts.bufnr,
    not opts.quiet and has_explicit_formatters,
    opts.stop_after_first
  )
  local has_lsp = has_lsp_formatter(opts)

  ---Handle errors and maybe run LSP formatting after cli formatters complete
  ---@param err? conform.Error
  ---@param did_edit? boolean
  local function handle_result(err, did_edit)
    if err then
      local level = errors.level_for_code(err.code)
      log.log(level, err.message)
      ---@type boolean?
      local should_notify = not opts.quiet and level >= vim.log.levels.WARN
      -- Execution errors have special handling. Maybe should reconsider this.
      local notify_msg = err.message
      if errors.is_execution_error(err.code) then
        should_notify = should_notify and M.notify_on_error and not err.debounce_message
        notify_msg = "Formatter failed. See :ConformInfo for details"
      end
      if should_notify then
        notify(notify_msg, level)
      end
    end
    local err_message = err and err.message
    if not err_message and not vim.api.nvim_buf_is_valid(opts.bufnr) then
      err_message = "buffer was deleted"
    end
    if err_message then
      return callback(err_message)
    end

    if opts.dry_run and did_edit then
      callback(nil, true)
    elseif opts.lsp_format == "last" and has_lsp then
      log.debug("Running LSP formatter on %s", vim.api.nvim_buf_get_name(opts.bufnr))
      lsp_format.format(opts, callback)
    else
      callback(nil, did_edit)
    end
  end

  ---Run the resolved formatters on the buffer
  local function run_cli_formatters(cb)
    local resolved_names = vim.tbl_map(function(f)
      return f.name
    end, formatters)
    log.debug("Running formatters on %s: %s", vim.api.nvim_buf_get_name(opts.bufnr), resolved_names)
    ---@type conform.RunOpts
    local run_opts = { exclusive = true, dry_run = opts.dry_run, undojoin = opts.undojoin }
    if opts.async then
      runner.format_async(opts.bufnr, formatters, opts.range, run_opts, cb)
    else
      local err, did_edit =
        runner.format_sync(opts.bufnr, formatters, opts.timeout_ms, opts.range, run_opts)
      cb(err, did_edit)
    end
  end

  -- check if at least one of the configured formatters is available
  local any_formatters = not vim.tbl_isempty(formatters)

  if
    has_lsp
    and (opts.lsp_format == "prefer" or (opts.lsp_format ~= "never" and not any_formatters))
  then
    -- LSP formatting only
    log.debug("Running LSP formatter on %s", vim.api.nvim_buf_get_name(opts.bufnr))
    lsp_format.format(opts, callback)
    return true
  elseif has_lsp and opts.lsp_format == "first" then
    -- LSP formatting, then other formatters
    log.debug("Running LSP formatter on %s", vim.api.nvim_buf_get_name(opts.bufnr))
    lsp_format.format(opts, function(err, did_edit)
      if err or (did_edit and opts.dry_run) then
        return callback(err, did_edit)
      end
      run_cli_formatters(function(err2, did_edit2)
        handle_result(err2, did_edit or did_edit2)
      end)
    end)
    return true
  elseif not vim.tbl_isempty(formatters) then
    run_cli_formatters(handle_result)
    return true
  else
    local level = has_explicit_formatters and "warn" or "debug"
    log[level]("Formatters unavailable for %s", vim.api.nvim_buf_get_name(opts.bufnr))

    local ft = vim.bo[opts.bufnr].filetype
    if
      not vim.tbl_isempty(formatter_names)
      and not has_notified_ft_no_formatters[ft]
      and not opts.quiet
      and M.notify_no_formatters
    then
      notify(string.format("Formatters unavailable for %s file", ft), vim.log.levels.WARN)
      has_notified_ft_no_formatters[ft] = true
    end

    callback("No formatters available for buffer")
    return false
  end
end

---Process lines with formatters
---@private
---@param formatter_names string[]
---@param lines string[]
---@param opts? conform.FormatLinesOpts
---@param callback? fun(err: nil|conform.Error, lines: nil|string[]) Called once formatting has completed
---@return nil|conform.Error error Only present if async = false
---@return nil|string[] new_lines Only present if async = false
M.format_lines = function(formatter_names, lines, opts, callback)
  ---@type {timeout_ms: integer, bufnr: integer, async: boolean, quiet: boolean, stop_after_first: boolean}
  opts = vim.tbl_extend("keep", opts or {}, {
    timeout_ms = 1000,
    bufnr = 0,
    async = false,
    quiet = false,
    stop_after_first = false,
  })
  callback = callback or function(_err, _lines) end
  local errors = require("conform.errors")
  local log = require("conform.log")
  local runner = require("conform.runner")
  local formatters =
    M.resolve_formatters(formatter_names, opts.bufnr, not opts.quiet, opts.stop_after_first)
  if vim.tbl_isempty(formatters) then
    callback(nil, lines)
    return
  end

  ---@param err? conform.Error
  ---@param new_lines? string[]
  local function handle_err(err, new_lines)
    if err then
      local level = errors.level_for_code(err.code)
      log.log(level, err.message)
    end
    callback(err, new_lines)
  end

  ---@type conform.RunOpts
  local run_opts = { exclusive = false, dry_run = false, undojoin = false }
  if opts.async then
    runner.format_lines_async(opts.bufnr, formatters, nil, lines, run_opts, handle_err)
  else
    local err, new_lines =
      runner.format_lines_sync(opts.bufnr, formatters, opts.timeout_ms, nil, lines, run_opts)
    handle_err(err, new_lines)
    return err, new_lines
  end
end

---Retrieve the available formatters for a buffer
---@param bufnr? integer
---@return conform.FormatterInfo[]
M.list_formatters = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local formatters = M.list_formatters_for_buffer(bufnr)
  return M.resolve_formatters(formatters, bufnr, false, false)
end

---Get the exact formatters that will be run for a buffer.
---@param bufnr? integer
---@return conform.FormatterInfo[]
---@return boolean lsp Will use LSP formatter
---@note
--- This accounts for stop_after_first, lsp fallback logic, etc.
M.list_formatters_to_run = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  ---@type {bufnr: integer, lsp_format: conform.LspFormatOpts, stop_after_first: boolean}
  local opts = vim.tbl_extend(
    "keep",
    get_opts_from_filetype(bufnr) or {},
    M.default_format_opts,
    { stop_after_first = false, lsp_format = "never", bufnr = bufnr }
  )
  local formatter_names = M.list_formatters_for_buffer(bufnr)
  local formatters = M.resolve_formatters(formatter_names, bufnr, false, opts.stop_after_first)

  local has_lsp = has_lsp_formatter(opts)
  local any_formatters = not vim.tbl_isempty(formatters)

  if
    has_lsp
    and (opts.lsp_format == "prefer" or (opts.lsp_format ~= "never" and not any_formatters))
  then
    return {}, true
  elseif has_lsp and opts.lsp_format == "first" then
    return formatters, true
  elseif not vim.tbl_isempty(formatters) then
    return formatters, opts.lsp_format == "last" and has_lsp
  else
    return {}, false
  end
end

---List information about all filetype-configured formatters
---@return conform.FormatterInfo[]
M.list_all_formatters = function()
  local formatters = {}
  for _, ft_formatters in pairs(M.formatters_by_ft) do
    if type(ft_formatters) == "function" then
      ft_formatters = ft_formatters(0)
    end

    for _, formatter in ipairs(ft_formatters) do
      assert(
        type(formatter) == "string",
        "The nested {} syntax to run the first formatter has been replaced by the stop_after_first option (see :help conform.format)."
      )
      formatters[formatter] = true
    end
  end

  ---@type conform.FormatterInfo[]
  local all_info = {}
  for formatter in pairs(formatters) do
    local info = M.get_formatter_info(formatter)
    table.insert(all_info, info)
  end

  table.sort(all_info, function(a, b)
    return a.name < b.name
  end)
  return all_info
end

---@private
---@param formatter string
---@param bufnr? integer
---@return nil|conform.FormatterConfig
M.get_formatter_config = function(formatter, bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  ---@type nil|conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride
  local override = M.formatters[formatter]
  if type(override) == "function" then
    override = override(bufnr)
  end
  if override and override.command and override.format then
    local msg =
      string.format("Formatter '%s' cannot define both 'command' and 'format' function", formatter)
    notify_once(msg, vim.log.levels.ERROR)
    return nil
  end

  ---@type nil|conform.FormatterConfig
  local config = override
  if not override or override.inherit ~= false then
    local ok, mod_config = pcall(require, "conform.formatters." .. formatter)
    if ok then
      if override then
        config = require("conform.util").merge_formatter_configs(mod_config, override)
      else
        config = mod_config
      end
    elseif override then
      if override.command or override.format then
        config = override
      else
        local msg = string.format(
          "Formatter '%s' missing built-in definition\nSet `command` to get rid of this error.",
          formatter
        )
        notify_once(msg, vim.log.levels.ERROR)
        return nil
      end
    else
      return nil
    end
  end

  if config and config.stdin == nil then
    config.stdin = true
  end
  return config
end

---Get information about a formatter (including availability)
---@param formatter string The name of the formatter
---@param bufnr? integer
---@return conform.FormatterInfo
M.get_formatter_info = function(formatter, bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local config = M.get_formatter_config(formatter, bufnr)
  if not config then
    return {
      name = formatter,
      command = formatter,
      available = false,
      available_msg = "Unknown formatter. Formatter config missing or incomplete",
      error = true,
    }
  end

  local ctx = require("conform.runner").build_context(bufnr, config)

  local available = true
  local available_msg = nil
  if config.format then
    ---@cast config conform.LuaFormatterConfig
    if config.condition and not config:condition(ctx) then
      available = false
      available_msg = "Condition failed"
    end
    return {
      name = formatter,
      command = formatter,
      available = available,
      available_msg = available_msg,
    }
  end

  local command = config.command
  if type(command) == "function" then
    ---@cast config conform.JobFormatterConfig
    command = command(config, ctx)
  end

  if vim.fn.executable(command) == 0 then
    available = false
    available_msg = string.format("Command '%s' not found", command)
  elseif config.condition and not config.condition(config, ctx) then
    available = false
    available_msg = "Condition failed"
  end
  local cwd = nil
  if config.cwd then
    ---@cast config conform.JobFormatterConfig
    cwd = config.cwd(config, ctx)
    if available and not cwd and config.require_cwd then
      available = false
      available_msg = "Root directory not found"
    end
  end

  ---@type conform.FormatterInfo
  return {
    name = formatter,
    command = command,
    cwd = cwd,
    available = available,
    available_msg = available_msg,
  }
end

M.formatexpr = function(opts)
  -- Change the defaults slightly from conform.format
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    timeout_ms = 500,
    lsp_format = "fallback",
    bufnr = vim.api.nvim_get_current_buf(),
  })
  -- Force async = false
  opts.async = false
  if vim.tbl_contains({ "i", "R", "ic", "ix" }, vim.fn.mode()) then
    -- `formatexpr` is also called when exceeding `textwidth` in insert mode
    -- fall back to internal formatting
    return 1
  end

  local start_lnum = vim.v.lnum
  local end_lnum = start_lnum + vim.v.count - 1

  if start_lnum <= 0 or end_lnum <= 0 then
    return 0
  end
  local end_line = vim.fn.getline(end_lnum)
  local end_col = end_line:len()

  if vim.v.count == vim.fn.line("$") then
    -- Whole buffer is selected; use buffer formatting
    opts.range = nil
  else
    opts.range = {
      start = { start_lnum, 0 },
      ["end"] = { end_lnum, end_col },
    }
  end

  M.format(opts)
  return 0
end

return M
