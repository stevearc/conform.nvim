---This module replaces the default vim.lsp.buf.format() so that we can inject our own logic
local ms = require("vim.lsp.protocol").Methods
local util = require("vim.lsp.util")

local M = {}

local function apply_text_edits(text_edits, bufnr, offset_encoding)
  if
    #text_edits == 1
    and text_edits[1].range.start.line == 0
    and text_edits[1].range.start.character == 0
    and text_edits[1].range["end"].line == vim.api.nvim_buf_line_count(bufnr) + 1
    and text_edits[1].range["end"].character == 0
  then
    local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local new_lines = vim.split(text_edits[1].newText, "\n", { plain = true })
    require("conform.runner").apply_format(bufnr, original_lines, new_lines, nil, false)
  else
    M.original_apply_text_edits(text_edits, bufnr, offset_encoding)
  end
end

---@param options table
---@param callback fun(err?: string)
function M.format(options, callback)
  options = options or {}
  local bufnr = options.bufnr or vim.api.nvim_get_current_buf()
  local range = options.range
  local method = range and ms.textDocument_rangeFormatting or ms.textDocument_formatting

  local clients = vim.lsp.get_clients({
    id = options.id,
    bufnr = bufnr,
    name = options.name,
    method = method,
  })
  if options.filter then
    clients = vim.tbl_filter(options.filter, clients)
  end

  if #clients == 0 then
    return callback("[LSP] Format request failed, no matching language servers.")
  end

  local function set_range(client, params)
    if range then
      local range_params =
        util.make_given_range_params(range.start, range["end"], bufnr, client.offset_encoding)
      params.range = range_params.range
    end
    return params
  end

  if options.async then
    local do_format
    do_format = function(idx, client)
      if not client then
        return callback()
      end
      local params = set_range(client, util.make_formatting_params(options.formatting_options))
      client.request(method, params, function(err, result, ctx, _)
        if not result then
          return callback(err)
        end
        apply_text_edits(result, ctx.bufnr, client.offset_encoding)

        do_format(next(clients, idx))
      end, bufnr)
    end
    do_format(next(clients))
  else
    local timeout_ms = options.timeout_ms or 1000
    for _, client in pairs(clients) do
      local params = set_range(client, util.make_formatting_params(options.formatting_options))
      local result, err = client.request_sync(method, params, timeout_ms, bufnr)
      if result and result.result then
        apply_text_edits(result.result, bufnr, client.offset_encoding)
      elseif err then
        return callback(string.format("[LSP][%s] %s", client.name, err))
      end
    end
    callback()
  end
end

return M
