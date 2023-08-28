local M = {}

---@class (exact) conform.FormatterInfo
---@field name string
---@field command string
---@field cwd? string
---@field available boolean
---@field available_msg? string

---@class (exact) conform.StaticFormatterConfig
---@field command string|fun(ctx: conform.Context): string
---@field args? string[]|fun(ctx: conform.Context): string[]
---@field cwd? fun(ctx: conform.Context): nil|string
---@field require_cwd? boolean When cwd is not found, don't run the formatter (default false)
---@field stdin? boolean Send buffer contents to stdin (default true)
---@field condition? fun(ctx: conform.Context): boolean
---@field exit_codes? integer[] Exit codes that indicate success (default {0})

---@class (exact) conform.FormatterConfig : conform.StaticFormatterConfig
---@field meta conform.FormatterMeta

---@class (exact) conform.FormatterMeta
---@field url string
---@field description string
---
---@class (exact) conform.Context
---@field buf integer
---@field filename string
---@field dirname string

---@class (exact) conform.RunOptions
---@field run_all_formatters nil|boolean Run all listed formatters instead of stopping at the first one.
---@field format_on_save nil|boolean Run these formatters in the built-in format_on_save autocmd.

---@class (exact) conform.FormatterList : conform.RunOptions
---@field formatters string[]

---@type table<string, string[]|conform.FormatterList>
M.formatters_by_ft = {}

---@type table<string, conform.StaticFormatterConfig|fun(): conform.StaticFormatterConfig>
M.formatters = {}

M.setup = function(opts)
  opts = opts or {}

  M.formatters = vim.tbl_extend("force", M.formatters, opts.formatters or {})
  M.formatters_by_ft = vim.tbl_extend("force", M.formatters_by_ft, opts.formatters_by_ft or {})

  if opts.log_level then
    require("conform.log").level = opts.log_level
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
        local filetypes = vim.split(vim.bo[args.buf].filetype, ".", { plain = true })
        for _, ft in ipairs(filetypes) do
          local ft_formatters = M.formatters_by_ft[ft]
          if ft_formatters and ft_formatters.format_on_save == false then
            return
          end
        end
        M.format(format_opts)
      end,
    })
  end

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.handlers["textDocument/formatting"] = function(_, result, ctx, _)
    if not result then
      return
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local restore = require("conform.util").save_win_positions(ctx.bufnr)
    vim.lsp.util.apply_text_edits(result, ctx.bufnr, client.offset_encoding)
    restore()
  end
end

---Format a buffer
---@param opts? table
---    timeout_ms nil|integer Time in milliseconds to block for formatting. Defaults to 1000. No effect if async = true.
---    bufnr nil|integer Format this buffer (default 0)
---    async nil|boolean If true the method won't block. Defaults to false.
---    formatters nil|string[] List of formatters to run. Defaults to all formatters for the buffer filetype.
---    lsp_fallback nil|boolean Attempt LSP formatting if no formatters are available. Defaults to false.
---@return boolean True if any formatters were attempted
M.format = function(opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    timeout_ms = 1000,
    bufnr = 0,
    async = false,
    lsp_fallback = false,
  })

  local formatters = {}
  if opts.formatters then
    for _, formatter in ipairs(opts.formatters) do
      local info = M.get_formatter_info(formatter)
      if info.available then
        table.insert(formatters, info)
      else
        vim.notify(
          string.format("Formatter '%s' unavailable: %s", info.name, info.available_msg),
          vim.log.levels.WARN
        )
      end
    end
  else
    formatters = M.list_formatters(opts.bufnr)
  end
  local any_formatters = not vim.tbl_isempty(formatters)
  if any_formatters then
    if opts.async then
      require("conform.runner").format_async(opts.bufnr, formatters)
    else
      require("conform.runner").format_sync(opts.bufnr, formatters, opts.timeout_ms)
    end
  end

  if not any_formatters then
    if opts.lsp_fallback then
      local supports_lsp_formatting = false
      for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = opts.bufnr })) do
        if client.server_capabilities.documentFormattingProvider then
          supports_lsp_formatting = true
          break
        end
      end

      if supports_lsp_formatting then
        local restore = require("conform.util").save_win_positions(opts.bufnr)
        vim.lsp.buf.format(opts)
        if not opts.async then
          restore()
        end
      end
    else
      vim.notify("No formatters found for buffer. See :checkhealth conform", vim.log.levels.WARN)
    end
  end

  return any_formatters
end

---Retried the available formatters for a buffer
---@param bufnr? integer
---@return conform.FormatterInfo[]
M.list_formatters = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local formatters = {}
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
        formatters[formatter] = true
      end
    end
  end

  ---@type conform.FormatterInfo[]
  local all_info = {}
  for formatter in pairs(formatters) do
    local info = M.get_formatter_info(formatter)
    if info.available then
      table.insert(all_info, info)
      if not run_options.run_all_formatters then
        break
      end
    end
  end

  return all_info
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
---@return nil|conform.StaticFormatterConfig
M.get_formatter_config = function(formatter)
  local config = M.formatters[formatter]
  if not config then
    local ok
    ok, config = pcall(require, "conform.formatters." .. formatter)
    if not ok then
      return nil
    end
  end
  if type(config) == "function" then
    config = config()
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
  local config = M.get_formatter_config(formatter)
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
