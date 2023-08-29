local M = {}

---@class (exact) conform.FormatterInfo
---@field name string
---@field command string
---@field cwd? string
---@field available boolean
---@field available_msg? string

---@class (exact) conform.FormatterConfig
---@field command string|fun(ctx: conform.Context): string
---@field args? string[]|fun(ctx: conform.Context): string[]
---@field range_args? fun(ctx: conform.RangeContext): string[]
---@field cwd? fun(ctx: conform.Context): nil|string
---@field require_cwd? boolean When cwd is not found, don't run the formatter (default false)
---@field stdin? boolean Send buffer contents to stdin (default true)
---@field condition? fun(ctx: conform.Context): boolean
---@field exit_codes? integer[] Exit codes that indicate success (default {0})
---@field env? table<string, any>|fun(ctx: conform.Context): table<string, any>

---@class (exact) conform.FileFormatterConfig : conform.FormatterConfig
---@field meta conform.FormatterMeta

---@class (exact) conform.FormatterMeta
---@field url string
---@field description string

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

---@class (exact) conform.RunOptions
---@field run_all_formatters nil|boolean Run all listed formatters instead of stopping at the first one.

---@class (exact) conform.FormatterList : conform.RunOptions
---@field formatters string[]

---@type table<string, string[]|conform.FormatterList>
M.formatters_by_ft = {}

---@type table<string, conform.FormatterConfig|fun(bufnr: integer): nil|conform.FormatterConfig>
M.formatters = {}

M.setup = function(opts)
  opts = opts or {}

  M.formatters = vim.tbl_extend("force", M.formatters, opts.formatters or {})
  M.formatters_by_ft = vim.tbl_extend("force", M.formatters_by_ft, opts.formatters_by_ft or {})

  if opts.log_level then
    require("conform.log").level = opts.log_level
  end

  for ft, formatters in pairs(M.formatters_by_ft) do
    ---@diagnostic disable-next-line: undefined-field
    if formatters.format_on_save ~= nil then
      vim.notify(
        string.format(
          'The "format_on_save" option for filetype "%s" is deprecated. It is recommended to create your own autocmd for fine grained control, see :help conform-autoformat',
          ft
        ),
        vim.log.levels.WARN
      )
      break
    end
  end

  if opts.format_on_save then
    if type(opts.format_on_save) == "boolean" then
      opts.format_on_save = {}
    end
    local aug = vim.api.nvim_create_augroup("Conform", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      group = aug,
      callback = function(args)
        local format_opts = vim.tbl_deep_extend("keep", opts.format_on_save, {
          buf = args.buf,
        })
        M.format(format_opts)
      end,
    })
  end

  vim.api.nvim_create_user_command("ConformInfo", function()
    require("conform.health").show_window()
  end, { desc = "Show information about Conform formatters" })

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.handlers["textDocument/formatting"] = function(_, result, ctx, _)
    if not result then
      return
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    assert(client)
    local restore = require("conform.util").save_win_positions(ctx.bufnr)
    vim.lsp.util.apply_text_edits(result, ctx.bufnr, client.offset_encoding)
    restore()
  end
end

---@param bufnr integer
---@return boolean
local function supports_lsp_format(bufnr)
  ---@diagnostic disable-next-line: deprecated
  for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
    if client.supports_method("textDocument/formatting", { bufnr = bufnr }) then
      return true
    end
  end
  return false
end

---@private
---@param bufnr? integer
---@return conform.FormatterInfo[]
---@return conform.RunOptions
M.list_formatters_for_buffer = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local formatters = {}
  local seen = {}
  local run_options = {
    run_all_formatters = false,
    format_on_save = true,
  }
  local filetypes = vim.split(vim.bo[bufnr].filetype, ".", { plain = true })
  table.insert(filetypes, "*")
  for _, filetype in ipairs(filetypes) do
    local ft_formatters = M.formatters_by_ft[filetype]
    if ft_formatters then
      if not vim.tbl_islist(ft_formatters) then
        for k, v in pairs(ft_formatters) do
          if k ~= "formatters" then
            run_options[k] = v
          end
        end
        ft_formatters = ft_formatters.formatters
      end
      for _, formatter in ipairs(ft_formatters) do
        if not seen[formatter] then
          table.insert(formatters, formatter)
          seen[formatter] = true
        end
      end
    end
  end

  ---@type conform.FormatterInfo[]
  local all_info = vim.tbl_map(function(f)
    return M.get_formatter_info(f, bufnr)
  end, formatters)

  return all_info, run_options
end

---@param formatters conform.FormatterInfo[]
---@param run_options conform.RunOptions
---@return conform.FormatterInfo[]
local function filter_formatters(formatters, run_options)
  ---@type conform.FormatterInfo[]
  local all_info = {}
  for _, info in ipairs(formatters) do
    if info.available then
      table.insert(all_info, info)
      if not run_options.run_all_formatters then
        break
      end
    end
  end

  return all_info
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

---Format a buffer
---@param opts? table
---    timeout_ms nil|integer Time in milliseconds to block for formatting. Defaults to 1000. No effect if async = true.
---    bufnr nil|integer Format this buffer (default 0)
---    async nil|boolean If true the method won't block. Defaults to false.
---    formatters nil|string[] List of formatters to run. Defaults to all formatters for the buffer filetype.
---    lsp_fallback nil|boolean Attempt LSP formatting if no formatters are available. Defaults to false.
---    quiet nil|boolean Don't show any notifications for warnings or failures. Defaults to false.
---    range nil|table Range to format. Table must contain `start` and `end` keys with {row, col} tuples using (1,0) indexing. Defaults to current selection in visual mode
---@return boolean True if any formatters were attempted
M.format = function(opts)
  ---@type {timeout_ms: integer, bufnr: integer, async: boolean, lsp_fallback: boolean, quiet: boolean, formatters?: string[], range?: conform.Range}
  opts = vim.tbl_extend("keep", opts or {}, {
    timeout_ms = 1000,
    bufnr = 0,
    async = false,
    lsp_fallback = false,
    quiet = false,
  })
  local log = require("conform.log")

  local formatters = {}
  local any_formatters_configured
  if opts.formatters then
    any_formatters_configured = true
    for _, formatter in ipairs(opts.formatters) do
      local info = M.get_formatter_info(formatter)
      if info.available then
        table.insert(formatters, info)
      else
        if opts.quiet then
          log.warn("Formatter '%s' unavailable: %s", info.name, info.available_msg)
        else
          vim.notify(
            string.format("Formatter '%s' unavailable: %s", info.name, info.available_msg),
            vim.log.levels.WARN
          )
        end
      end
    end
  else
    local run_info
    formatters, run_info = M.list_formatters_for_buffer(opts.bufnr)
    any_formatters_configured = not vim.tbl_isempty(formatters)
    formatters = filter_formatters(formatters, run_info)
  end
  local formatter_names = vim.tbl_map(function(f)
    return f.name
  end, formatters)
  log.debug("Running formatters on %s: %s", vim.api.nvim_buf_get_name(opts.bufnr), formatter_names)

  local any_formatters = not vim.tbl_isempty(formatters)
  if any_formatters then
    local mode = vim.api.nvim_get_mode().mode
    if not opts.range and mode == "v" or mode == "V" then
      opts.range = range_from_selection(opts.bufnr, mode)
    end

    if opts.async then
      require("conform.runner").format_async(opts.bufnr, formatters, opts.range)
    else
      require("conform.runner").format_sync(
        opts.bufnr,
        formatters,
        opts.timeout_ms,
        opts.quiet,
        opts.range
      )
    end
  elseif opts.lsp_fallback and supports_lsp_format(opts.bufnr) then
    log.debug("Running LSP formatter on %s", vim.api.nvim_buf_get_name(opts.bufnr))
    local restore = require("conform.util").save_win_positions(opts.bufnr)
    vim.lsp.buf.format(opts)
    if not opts.async then
      restore()
    end
  elseif any_formatters_configured and not opts.quiet then
    vim.notify("No formatters found for buffer. See :ConformInfo", vim.log.levels.WARN)
  else
    log.debug("No formatters found for %s", vim.api.nvim_buf_get_name(opts.bufnr))
  end

  return any_formatters
end

---Retrieve the available formatters for a buffer
---@param bufnr? integer
---@return conform.FormatterInfo[]
M.list_formatters = function(bufnr)
  local formatters, run_options = M.list_formatters_for_buffer(bufnr)
  return filter_formatters(formatters, run_options)
end

---List information about all filetype-configured formatters
---@return conform.FormatterInfo[]
M.list_all_formatters = function()
  local formatters = {}
  for _, ft_formatters in pairs(M.formatters_by_ft) do
    if not vim.tbl_islist(ft_formatters) then
      ft_formatters = ft_formatters.formatters
    end
    for _, formatter in ipairs(ft_formatters) do
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
  ---@type nil|conform.FormatterConfig|fun(bufnr: integer): nil|conform.FormatterConfig
  local config = M.formatters[formatter]
  if type(config) == "function" then
    config = config(bufnr)
  end
  if not config then
    local ok
    ok, config = pcall(require, "conform.formatters." .. formatter)
    if not ok then
      return nil
    end
  end

  if config.stdin == nil then
    config.stdin = true
  end
  return config
end

---@private
---@param formatter string
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

  local command = config.command
  if type(command) == "function" then
    command = command(ctx)
  end

  local available = true
  local available_msg = nil
  if vim.fn.executable(command) == 0 then
    available = false
    available_msg = "Command not found"
  elseif config.condition and not config.condition(ctx) then
    available = false
    available_msg = "Condition failed"
  end
  local cwd = nil
  if config.cwd then
    cwd = config.cwd(ctx)
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

return M
