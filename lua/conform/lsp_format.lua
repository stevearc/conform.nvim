---This module replaces the default vim.lsp.buf.format() so that we can inject our own logic
local log = require("conform.log")
local util = require("vim.lsp.util")

local M = {}

local function apply_text_edits(text_edits, bufnr, offset_encoding, dry_run)
  if
    #text_edits == 1
    and text_edits[1].range.start.line == 0
    and text_edits[1].range.start.character == 0
    and text_edits[1].range["end"].line >= vim.api.nvim_buf_line_count(bufnr)
    and text_edits[1].range["end"].character == 0
  then
    local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local new_lines = vim.split(text_edits[1].newText, "\r?\n", {})
    -- If it had a trailing newline, remove it to make the lines match the expected vim format
    if #new_lines > 1 and new_lines[#new_lines] == "" then
      table.remove(new_lines)
    end
    log.debug("Converting full-file LSP format to piecewise format")
    return require("conform.runner").apply_format(
      bufnr,
      original_lines,
      new_lines,
      nil,
      false,
      dry_run
    )
  elseif dry_run then
    return #text_edits > 0
  else
    vim.lsp.util.apply_text_edits(text_edits, bufnr, offset_encoding)
    return #text_edits > 0
  end
end

---@param options table
---@return table[] clients
function M.get_format_clients(options)
  local method = options.range and "textDocument/rangeFormatting" or "textDocument/formatting"

  local clients
  if vim.lsp.get_clients then
    clients = vim.lsp.get_clients({
      id = options.id,
      bufnr = options.bufnr,
      name = options.name,
      method = method,
    })
  else
    clients = vim.lsp.get_active_clients({
      id = options.id,
      bufnr = options.bufnr,
      name = options.name,
    })

    clients = vim.tbl_filter(function(client)
      return client.supports_method(method, { bufnr = options.bufnr })
    end, clients)
  end
  if options.filter then
    clients = vim.tbl_filter(options.filter, clients)
  end
  return clients
end

---@param options table
---@param callback fun(err?: string, did_edit?: boolean)
function M.format(options, callback)
  options = options or {}
  if not options.bufnr or options.bufnr == 0 then
    options.bufnr = vim.api.nvim_get_current_buf()
  end
  local bufnr = options.bufnr
  local range = options.range
  local method = range and "textDocument/rangeFormatting" or "textDocument/formatting"

  local clients = M.get_format_clients(options)

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
    local changedtick = vim.b[bufnr].changedtick
    local do_format
    local did_edit = false
    do_format = function(idx, client)
      if not client then
        return callback(nil, did_edit)
      end
      local params = set_range(client, util.make_formatting_params(options.formatting_options))
      local auto_id = vim.api.nvim_create_autocmd("LspDetach", {
        buffer = bufnr,
        callback = function(args)
          if args.data.client_id == client.id then
            log.warn("LSP %s detached during format request", client.name)
            callback("LSP detached")
          end
        end,
      })
      client.request(method, params, function(err, result, ctx, _)
        vim.api.nvim_del_autocmd(auto_id)
        if not result then
          return callback(err or "No result returned from LSP formatter")
        elseif not vim.api.nvim_buf_is_valid(bufnr) then
          return callback("buffer was deleted")
        elseif changedtick ~= require("conform.util").buf_get_changedtick(bufnr) then
          return callback(
            string.format(
              "Async LSP formatter discarding changes for %s: concurrent modification",
              vim.api.nvim_buf_get_name(bufnr)
            )
          )
        else
          local this_did_edit =
            apply_text_edits(result, ctx.bufnr, client.offset_encoding, options.dry_run)
          changedtick = vim.b[bufnr].changedtick

          if options.dry_run and this_did_edit then
            callback(nil, true)
          else
            did_edit = did_edit or this_did_edit
            do_format(next(clients, idx))
          end
        end
      end, bufnr)
    end
    do_format(next(clients))
  else
    local timeout_ms = options.timeout_ms or 1000
    local did_edit = false
    for _, client in pairs(clients) do
      local params = set_range(client, util.make_formatting_params(options.formatting_options))
      local result, err = client.request_sync(method, params, timeout_ms, bufnr)
      if result and result.result then
        local this_did_edit =
          apply_text_edits(result.result, bufnr, client.offset_encoding, options.dry_run)
        did_edit = did_edit or this_did_edit

        if options.dry_run and did_edit then
          callback(nil, true)
          return true
        end
      elseif err then
        if not options.quiet then
          vim.notify(string.format("[LSP][%s] %s", client.name, err), vim.log.levels.WARN)
        end
        return callback(string.format("[LSP][%s] %s", client.name, err))
      end
    end
    callback(nil, did_edit)
  end
end

return M
