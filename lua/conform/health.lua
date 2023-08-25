local M = {}

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
      local filetypes = {}
      for filetype, formatters in pairs(conform.formatters_by_ft) do
        if not vim.tbl_islist(formatters) then
          formatters = formatters.formatters
        end
        if vim.tbl_contains(formatters, formatter.name) then
          table.insert(filetypes, filetype)
        end
      end

      vim.health.report_ok(
        string.format("%s ready (%s)", formatter.name, table.concat(filetypes, ", "))
      )
    end
  end
end

return M
