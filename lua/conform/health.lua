local M = {}

---@param name string
---@return string[]
local function get_formatter_filetypes(name)
  local conform = require("conform")
  local filetypes = {}
  for filetype, formatters in pairs(conform.formatters_by_ft) do
    if type(formatters) == "function" then
      formatters = formatters(0)
    end

    for _, ft_name in ipairs(formatters) do
      if type(ft_name) == "string" then
        if ft_name == name then
          table.insert(filetypes, filetype)
          break
        end
      else
        if vim.tbl_contains(ft_name, name) then
          table.insert(filetypes, filetype)
          break
        end
      end
    end
  end
  return filetypes
end

M.check = function()
  local conform = require("conform")
  vim.health.start("conform.nvim report")

  local log = require("conform.log")
  if vim.fn.has("nvim-0.10") == 0 then
    vim.health.error("Neovim 0.10 or later is required")
  end
  vim.health.info(string.format("Log file: %s", log.get_logfile()))

  local all_formatters = conform.list_all_formatters()
  for _, formatter in ipairs(all_formatters) do
    if not formatter.available then
      vim.health.warn(string.format("%s unavailable: %s", formatter.name, formatter.available_msg))
    else
      local filetypes = get_formatter_filetypes(formatter.name)
      vim.health.ok(string.format("%s ready (%s)", formatter.name, table.concat(filetypes, ", ")))
    end
  end
end

---@param formatters conform.FiletypeFormatterInternal
---@return string[]
local function flatten_formatters(formatters)
  local flat = {}
  for _, name in ipairs(formatters) do
    if type(name) == "string" then
      table.insert(flat, name)
    else
      for _, f in ipairs(flatten_formatters(name)) do
        table.insert(flat, f)
      end
    end
  end
  return flat
end

M.show_window = function()
  local conform = require("conform")
  local log = require("conform.log")
  local lsp_format = require("conform.lsp_format")
  local lines = {}
  local highlights = {}
  local logfile = log.get_logfile()

  if vim.fn.has("nvim-0.10") == 0 then
    table.insert(lines, "Neovim 0.10 or later is required")
    table.insert(highlights, { "DiagnosticError", #lines, 0, #lines[#lines] })
  end

  table.insert(lines, string.format("Log file: %s", logfile))
  table.insert(highlights, { "Title", #lines, 0, 10 })
  if vim.fn.filereadable(logfile) == 1 then
    local f = io.open(logfile, "r")
    if f then
      local context = -1024
      -- Show more logs if the log level is set to trace.
      if log.level == vim.log.levels.TRACE then
        context = 3 * context
      end
      f:seek("end", context)
      local text = f:read("*a")
      f:close()
      local log_lines = vim.split(text, "\r?\n", { trimempty = true })
      for i = 2, #log_lines do
        table.insert(lines, string.rep(" ", 10) .. log_lines[i])
      end
    end
  end
  table.insert(lines, "")

  ---@param formatter conform.FormatterInfo
  local function append_formatter_info(formatter)
    if not formatter.available then
      local type_label = formatter.error and "error" or "unavailable"

      local line = string.format("%s %s: %s", formatter.name, type_label, formatter.available_msg)

      table.insert(lines, line)

      local hl = formatter.error and "DiagnosticError" or "DiagnosticWarn"
      local hl_start = formatter.name:len() + 1
      table.insert(highlights, { hl, #lines, hl_start, hl_start + type_label:len() })
    else
      local filetypes = get_formatter_filetypes(formatter.name)
      local filetypes_list = table.concat(filetypes, ", ")
      local path = vim.fn.exepath(formatter.command)
      local line = string.format("%s ready (%s) %s", formatter.name, filetypes_list, path)
      table.insert(lines, line)
      table.insert(
        highlights,
        { "DiagnosticOk", #lines, formatter.name:len(), formatter.name:len() + 6 }
      )
      table.insert(highlights, {
        "DiagnosticInfo",
        #lines,
        formatter.name:len() + 7 + filetypes_list:len() + 3,
        line:len(),
      })
    end
  end

  local seen = {}
  ---@param formatters string[]
  local function append_formatters(formatters)
    for _, name in ipairs(formatters) do
      if type(name) == "table" then
        append_formatters(name)
      else
        seen[name] = true
        local formatter = conform.get_formatter_info(name)
        append_formatter_info(formatter)
      end
    end
  end

  table.insert(lines, "Formatters for this buffer:")
  table.insert(highlights, { "Title", #lines, 0, #lines[#lines] })
  local lsp_clients = lsp_format.get_format_clients({ bufnr = vim.api.nvim_get_current_buf() })
  local has_lsp_formatter = not vim.tbl_isempty(lsp_clients)
  if has_lsp_formatter then
    table.insert(lines, "LSP: " .. table.concat(
      vim.tbl_map(function(c)
        return c.name
      end, lsp_clients),
      ", "
    ))
  end
  local buf_formatters = flatten_formatters(conform.list_formatters_for_buffer())
  append_formatters(buf_formatters)
  if vim.tbl_isempty(buf_formatters) and not has_lsp_formatter then
    table.insert(lines, "<none>")
  end

  table.insert(lines, "")
  table.insert(lines, "Other formatters:")
  table.insert(highlights, { "Title", #lines, 0, #lines[#lines] })
  for _, formatter in ipairs(conform.list_all_formatters()) do
    if not seen[formatter.name] then
      append_formatter_info(formatter)
    end
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local winid = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    border = "rounded",
    width = vim.o.columns - 6,
    height = vim.o.lines - 6,
    col = 2,
    row = 2,
    style = "minimal",
  })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].bufhidden = "wipe"
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr, nowait = true })
  vim.keymap.set("n", "<C-c>", "<cmd>close<cr>", { buffer = bufnr })
  vim.api.nvim_create_autocmd("BufLeave", {
    desc = "Close info window when leaving buffer",
    buffer = bufnr,
    once = true,
    nested = true,
    callback = function()
      if vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_close(winid, true)
      end
    end,
  })
  local ns = vim.api.nvim_create_namespace("conform")
  for _, hl in ipairs(highlights) do
    local group, lnum, col_start, col_end = unpack(hl)
    vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, col_start, {
      end_col = col_end,
      hl_group = group,
    })
  end
end

return M
