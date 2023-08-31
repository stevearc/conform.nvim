local M = {}

---@param name string
---@return string[]
local function get_formatter_filetypes(name)
  local conform = require("conform")
  local filetypes = {}
  for filetype, formatters in pairs(conform.formatters_by_ft) do
    if not vim.tbl_islist(formatters) then
      formatters = formatters.formatters
    end
    if vim.tbl_contains(formatters, name) then
      table.insert(filetypes, filetype)
    end
  end
  return filetypes
end

M.check = function()
  local conform = require("conform")
  vim.health.report_start("conform.nvim report")

  local log = require("conform.log")
  vim.health.info(string.format("Log file: %s", log.get_logfile()))

  local all_formatters = conform.list_all_formatters()
  for _, formatter in ipairs(all_formatters) do
    if not formatter.available then
      vim.health.report_warn(
        string.format("%s unavailable: %s", formatter.name, formatter.available_msg)
      )
    else
      local filetypes = get_formatter_filetypes(formatter.name)
      vim.health.report_ok(
        string.format("%s ready (%s)", formatter.name, table.concat(filetypes, ", "))
      )
    end
  end
end

M.show_window = function()
  local conform = require("conform")
  local lines = {}
  local highlights = {}
  local log = require("conform.log")
  local logfile = log.get_logfile()
  table.insert(lines, string.format("Log file: %s", logfile))
  table.insert(highlights, { "Title", #lines, 0, 10 })
  if vim.fn.filereadable(logfile) == 1 then
    local f = io.open(logfile, "r")
    if f then
      f:seek("end", -1024)
      local text = f:read("*a")
      f:close()
      local log_lines = vim.split(text, "\n", { plain = true, trimempty = true })
      for i = 2, #log_lines do
        table.insert(lines, string.rep(" ", 10) .. log_lines[i])
      end
    end
  end
  table.insert(lines, "")

  ---@param formatters conform.FormatterInfo[]
  local function append_formatters(formatters)
    for _, formatter in ipairs(formatters) do
      if not formatter.available then
        local line = string.format("%s unavailable: %s", formatter.name, formatter.available_msg)
        table.insert(lines, line)
        table.insert(
          highlights,
          { "DiagnosticWarn", #lines, formatter.name:len(), formatter.name:len() + 12 }
        )
      else
        local filetypes = get_formatter_filetypes(formatter.name)
        local line = string.format("%s ready (%s)", formatter.name, table.concat(filetypes, ", "))
        table.insert(lines, line)
        table.insert(
          highlights,
          { "DiagnosticInfo", #lines, formatter.name:len(), formatter.name:len() + 6 }
        )
      end
    end
  end

  table.insert(lines, "Formatters for this buffer:")
  table.insert(highlights, { "Title", #lines, 0, -1 })
  local seen = {}
  local buf_formatters = conform.list_formatters_for_buffer()
  for _, formatter in ipairs(buf_formatters) do
    seen[formatter.name] = true
  end
  append_formatters(buf_formatters)
  if vim.tbl_isempty(buf_formatters) then
    table.insert(lines, "<none>")
  end

  table.insert(lines, "")
  table.insert(lines, "Other formatters:")
  table.insert(highlights, { "Title", #lines, 0, -1 })
  local all_formatters = vim.tbl_filter(function(f)
    return not seen[f.name]
  end, conform.list_all_formatters())
  append_formatters(all_formatters)

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
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr })
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
    vim.api.nvim_buf_add_highlight(bufnr, ns, hl[1], hl[2] - 1, hl[3], hl[4])
  end
end

return M
