local M = {}

---@class (exact) conform.FormatterInfo
---@field name string
---@field command string
---@field cwd? string
---@field available boolean
---@field available_msg? string

---@class (exact) conform.JobFormatterConfig
---@field command string|fun(self: conform.JobFormatterConfig, ctx: conform.Context): string
---@field args? string|string[]|fun(self: conform.JobFormatterConfig, ctx: conform.Context): string|string[]
---@field range_args? fun(self: conform.JobFormatterConfig, ctx: conform.RangeContext): string|string[]
---@field cwd? fun(self: conform.JobFormatterConfig, ctx: conform.Context): nil|string
---@field require_cwd? boolean When cwd is not found, don't run the formatter (default false)
---@field stdin? boolean Send buffer contents to stdin (default true)
---@field condition? fun(self: conform.JobFormatterConfig, ctx: conform.Context): boolean
---@field exit_codes? integer[] Exit codes that indicate success (default {0})
---@field env? table<string, any>|fun(self: conform.JobFormatterConfig, ctx: conform.Context): table<string, any>
---@field options? table

---@class (exact) conform.LuaFormatterConfig
---@field format fun(self: conform.LuaFormatterConfig, ctx: conform.Context, lines: string[], callback: fun(err: nil|string, new_lines: nil|string[]))
---@field condition? fun(self: conform.LuaFormatterConfig, ctx: conform.Context): boolean
---@field options? table

---@class (exact) conform.FileLuaFormatterConfig : conform.LuaFormatterConfig
---@field meta conform.FormatterMeta

---@class (exact) conform.FileFormatterConfig : conform.JobFormatterConfig
---@field meta conform.FormatterMeta

---@alias conform.FormatterConfig conform.JobFormatterConfig|conform.LuaFormatterConfig

---@class (exact) conform.FormatterConfigOverride : conform.JobFormatterConfig
---@field inherit? boolean
---@field command? string|fun(self: conform.FormatterConfig, ctx: conform.Context): string
---@field prepend_args? string|string[]|fun(self: conform.FormatterConfig, ctx: conform.Context): string|string[]
---@field format? fun(self: conform.LuaFormatterConfig, ctx: conform.Context, lines: string[], callback: fun(err: nil|string, new_lines: nil|string[])) Mutually exclusive with command
---@field options? table

---@class (exact) conform.FormatterMeta
---@field url string
---@field description string
---@field deprecated? boolean

---@class (exact) conform.Context
---@field buf integer
---@field filename string
---@field dirname string
---@field range? conform.Range

---@class (exact) conform.RangeContext : conform.Context
---@field range conform.Range

---@class (exact) conform.Range
---@field start integer[]
---@field end integer[]

---@alias conform.FormatterUnit string|string[]
---@alias conform.FiletypeFormatter conform.FormatterUnit[]|fun(bufnr: integer): string[]

---@type table<string, conform.FiletypeFormatter>
M.formatters_by_ft = {}

---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
M.formatters = {}

M.notify_on_error = true

M.setup = function(opts)
  opts = opts or {}

  M.formatters = vim.tbl_extend("force", M.formatters, opts.formatters or {})
  M.formatters_by_ft = vim.tbl_extend("force", M.formatters_by_ft, opts.formatters_by_ft or {})

  if opts.log_level then
    require("conform.log").level = opts.log_level
  end
  if opts.notify_on_error ~= nil then
    M.notify_on_error = opts.notify_on_error
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

  vim.api.nvim_create_user_command("ConformInfo", function()
    require("conform.health").show_window()
  end, { desc = "Show information about Conform formatters" })
end

---Get the configured formatter filetype for a buffer
---@param bufnr? integer
---@return nil|string filetype or nil if no formatter is configured
local function get_matching_filetype(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local filetypes = vim.split(vim.bo[bufnr].filetype, ".", { plain = true })
  table.insert(filetypes, "_")
  for _, filetype in ipairs(filetypes) do
    local ft_formatters = M.formatters_by_ft[filetype]
    if ft_formatters then
      return filetype
    end
  end
end

---@private
---@param bufnr? integer
---@return conform.FormatterUnit[]
M.list_formatters_for_buffer = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local formatters = {}
  local seen = {}

  local function dedupe_formatters(names, collect)
    for _, name in ipairs(names) do
      if type(name) == "table" then
        local alternation = {}
        dedupe_formatters(name, alternation)
        if not vim.tbl_isempty(alternation) then
          table.insert(collect, alternation)
        end
      elseif not seen[name] then
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
        -- support the old structure where formatters could be a subkey
        if not vim.tbl_islist(ft_formatters) then
          vim.notify_once(
            "Using deprecated structure for formatters_by_ft. See :help conform-options for details.",
            vim.log.levels.ERROR
          )
          ---@diagnostic disable-next-line: undefined-field
          ft_formatters = ft_formatters.formatters
        end

        dedupe_formatters(ft_formatters, formatters)
      end
    end
  end

  return formatters
end

---@param bufnr integer
---@param mode "v"|"V"
---@return table {start={row,col}, end={row,col}} using (1, 0) indexing
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
---@param names conform.FormatterUnit[]
---@param bufnr integer
---@param warn_on_missing boolean
---@return conform.FormatterInfo[]
M.resolve_formatters = function(names, bufnr, warn_on_missing)
  local all_info = {}
  local function add_info(info, warn)
    if info.available then
      table.insert(all_info, info)
    elseif warn then
      vim.notify(
        string.format("Formatter '%s' unavailable: %s", info.name, info.available_msg),
        vim.log.levels.WARN
      )
    end
    return info.available
  end

  for _, name in ipairs(names) do
    if type(name) == "string" then
      local info = M.get_formatter_info(name, bufnr)
      add_info(info, warn_on_missing)
    else
      -- If this is an alternation, take the first one that's available
      for i, v in ipairs(name) do
        local info = M.get_formatter_info(v, bufnr)
        if add_info(info, warn_on_missing and i == #name) then
          break
        end
      end
    end
  end
  return all_info
end

---Format a buffer
---@param opts? table
---    timeout_ms nil|integer Time in milliseconds to block for formatting. Defaults to 1000. No effect if async = true.
---    bufnr nil|integer Format this buffer (default 0)
---    async nil|boolean If true the method won't block. Defaults to false. If the buffer is modified before the formatter completes, the formatting will be discarded.
---    dry_run nil|boolean If true don't apply formatting changes to the buffer
---    formatters nil|string[] List of formatters to run. Defaults to all formatters for the buffer filetype.
---    lsp_fallback nil|boolean|"always" Attempt LSP formatting if no formatters are available. Defaults to false. If "always", will attempt LSP formatting even if formatters are available.
---    quiet nil|boolean Don't show any notifications for warnings or failures. Defaults to false.
---    range nil|table Range to format. Table must contain `start` and `end` keys with {row, col} tuples using (1,0) indexing. Defaults to current selection in visual mode
---    id nil|integer Passed to |vim.lsp.buf.format| when lsp_fallback = true
---    name nil|string Passed to |vim.lsp.buf.format| when lsp_fallback = true
---    filter nil|fun(client: table): boolean Passed to |vim.lsp.buf.format| when lsp_fallback = true
---@param callback? fun(err: nil|string, did_edit: nil|boolean) Called once formatting has completed
---@return boolean True if any formatters were attempted
M.format = function(opts, callback)
  ---@type {timeout_ms: integer, bufnr: integer, async: boolean, dry_run: boolean, lsp_fallback: boolean|"always", quiet: boolean, formatters?: string[], range?: conform.Range}
  opts = vim.tbl_extend("keep", opts or {}, {
    timeout_ms = 1000,
    bufnr = 0,
    async = false,
    dry_run = false,
    lsp_fallback = false,
    quiet = false,
  })
  if opts.bufnr == 0 then
    opts.bufnr = vim.api.nvim_get_current_buf()
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

  local explicit_formatters = opts.formatters ~= nil
  local formatter_names = opts.formatters or M.list_formatters_for_buffer(opts.bufnr)
  local formatters =
    M.resolve_formatters(formatter_names, opts.bufnr, not opts.quiet and explicit_formatters)

  local any_formatters = not vim.tbl_isempty(formatters)
  if not explicit_formatters and opts.lsp_fallback == true and M.will_fallback_lsp(opts) then
    -- use the LSP formatter when the configured formatters are from the fallback "_" filetype
    any_formatters = false
  else
    local resolved_names = vim.tbl_map(function(f)
      return f.name
    end, formatters)
    log.debug("Running formatters on %s: %s", vim.api.nvim_buf_get_name(opts.bufnr), resolved_names)
  end

  if any_formatters then
    ---@param err? conform.Error
    ---@param did_edit? boolean
    local function handle_result(err, did_edit)
      if err then
        local level = errors.level_for_code(err.code)
        log.log(level, err.message)
        local should_notify = not opts.quiet and level >= vim.log.levels.WARN
        -- Execution errors have special handling. Maybe should reconsider this.
        local notify_msg = err.message
        if errors.is_execution_error(err.code) then
          should_notify = should_notify and M.notify_on_error and not err.debounce_message
          notify_msg = "Formatter failed. See :ConformInfo for details"
        end
        if should_notify then
          vim.notify(notify_msg, level)
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
      elseif
        opts.lsp_fallback == "always" and not vim.tbl_isempty(lsp_format.get_format_clients(opts))
      then
        log.debug("Running LSP formatter on %s", vim.api.nvim_buf_get_name(opts.bufnr))
        lsp_format.format(opts, callback)
      else
        callback(nil, did_edit)
      end
    end

    local run_opts = { exclusive = true, dry_run = opts.dry_run }
    if opts.async then
      runner.format_async(opts.bufnr, formatters, opts.range, run_opts, handle_result)
    else
      local err, did_edit =
        runner.format_sync(opts.bufnr, formatters, opts.timeout_ms, opts.range, run_opts)
      handle_result(err, did_edit)
    end
    return true
  elseif opts.lsp_fallback and not vim.tbl_isempty(lsp_format.get_format_clients(opts)) then
    log.debug("Running LSP formatter on %s", vim.api.nvim_buf_get_name(opts.bufnr))
    lsp_format.format(opts, callback)
    return true
  else
    local level = vim.tbl_isempty(formatter_names) and "debug" or "warn"
    log[level]("No formatters found for %s", vim.api.nvim_buf_get_name(opts.bufnr))
    callback("No formatters found for buffer")
    return false
  end
end

---Process lines with formatters
---@private
---@param formatter_names string[]
---@param lines string[]
---@param opts? table
---    timeout_ms nil|integer Time in milliseconds to block for formatting. Defaults to 1000. No effect if async = true.
---    bufnr nil|integer use this as the working buffer (default 0)
---    async nil|boolean If true the method won't block. Defaults to false. If the buffer is modified before the formatter completes, the formatting will be discarded.
---    quiet nil|boolean Don't show any notifications for warnings or failures. Defaults to false.
---@param callback? fun(err: nil|conform.Error, lines: nil|string[]) Called once formatting has completed
---@return nil|conform.Error error Only present if async = false
---@return nil|string[] new_lines Only present if async = false
M.format_lines = function(formatter_names, lines, opts, callback)
  ---@type {timeout_ms: integer, bufnr: integer, async: boolean, quiet: boolean}
  opts = vim.tbl_extend("keep", opts or {}, {
    timeout_ms = 1000,
    bufnr = 0,
    async = false,
    quiet = false,
  })
  callback = callback or function(_err, _lines) end
  local errors = require("conform.errors")
  local log = require("conform.log")
  local runner = require("conform.runner")
  local formatters = M.resolve_formatters(formatter_names, opts.bufnr, not opts.quiet)
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

  local run_opts = { exclusive = false, dry_run = false }
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
  return M.resolve_formatters(formatters, bufnr, false)
end

---List information about all filetype-configured formatters
---@return conform.FormatterInfo[]
M.list_all_formatters = function()
  local formatters = {}
  for _, ft_formatters in pairs(M.formatters_by_ft) do
    if type(ft_formatters) == "function" then
      ft_formatters = ft_formatters(0)
    end
    -- support the old structure where formatters could be a subkey
    if not vim.tbl_islist(ft_formatters) then
      vim.notify_once(
        "Using deprecated structure for formatters_by_ft. See :help conform-options for details.",
        vim.log.levels.ERROR
      )
      ---@diagnostic disable-next-line: undefined-field
      ft_formatters = ft_formatters.formatters
    end

    for _, formatter in ipairs(ft_formatters) do
      if type(formatter) == "table" then
        for _, v in ipairs(formatter) do
          formatters[v] = true
        end
      else
        formatters[formatter] = true
      end
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
    vim.notify_once(msg, vim.log.levels.ERROR)
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
        vim.notify_once(msg, vim.log.levels.ERROR)
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
      available_msg = "No config found",
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
    available_msg = "Command not found"
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

---Check if the buffer will use LSP formatting when lsp_fallback = true
---@param options? table Options passed to |vim.lsp.buf.format|
---@return boolean
M.will_fallback_lsp = function(options)
  options = vim.tbl_deep_extend("keep", options or {}, {
    bufnr = vim.api.nvim_get_current_buf(),
  })
  if options.bufnr == 0 then
    options.bufnr = vim.api.nvim_get_current_buf()
  end
  local matching_filetype = get_matching_filetype(options.bufnr)
  local has_primary_formatters = matching_filetype and matching_filetype ~= "_"
  local lsp_clients = require("conform.lsp_format").get_format_clients(options)
  return not has_primary_formatters and not vim.tbl_isempty(lsp_clients)
end

M.formatexpr = function(opts)
  local lsp_format = require("conform.lsp_format")
  -- Change the defaults slightly from conform.format
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    timeout_ms = 500,
    lsp_fallback = true,
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

  if M.format(opts) then
    return 0
  elseif opts.lsp_fallback and not vim.tbl_isempty(lsp_format.get_format_clients(opts)) then
    -- No formatters were available; fall back to lsp formatter
    return vim.lsp.formatexpr({ timeout_ms = opts.timeout_ms })
  else
    -- Do not fallback to built-in formatter.
    return 0
  end
end

return M
