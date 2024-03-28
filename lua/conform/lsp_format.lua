---This module replaces the default vim.lsp.buf.format() so that we can inject our own logic
local log = require("conform.log")

local M = {}

local function apply_text_edits(text_edits, bufnr, offset_encoding, dry_run)
  text_edits = M.diff_text_edits(text_edits, bufnr)
  if not dry_run then
    log.trace("Applying text edits: %s", text_edits)
    vim.lsp.util.apply_text_edits(text_edits, bufnr, offset_encoding)
    log.trace("Done formatting %s", vim.api.nvim_buf_get_name(bufnr))
  end
  return #text_edits > 0
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
      local range_params = vim.lsp.util.make_given_range_params(
        range.start,
        range["end"],
        bufnr,
        client.offset_encoding
      )
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
      local params =
        set_range(client, vim.lsp.util.make_formatting_params(options.formatting_options))
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
      local params =
        set_range(client, vim.lsp.util.make_formatting_params(options.formatting_options))
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

---@param range conform.Range
---@param start_a integer
---@param end_a integer
---@return boolean
local function indices_in_range(range, start_a, end_a)
  return start_a <= range["end"][1] and range["start"][1] <= end_a
end

---@param a? string
---@param b? string
---@return integer
local function common_prefix_len(a, b)
  if not a or not b then
    return 0
  end
  local min_len = math.min(#a, #b)
  for i = 1, min_len do
    if string.byte(a, i) ~= string.byte(b, i) then
      return i - 1
    end
  end
  return min_len
end

---@param a string
---@param b string
---@return integer
local function common_suffix_len(a, b)
  local a_len = #a
  local b_len = #b
  local min_len = math.min(a_len, b_len)
  for i = 0, min_len - 1 do
    if string.byte(a, a_len - i) ~= string.byte(b, b_len - i) then
      return i
    end
  end
  return min_len
end

local function create_text_edit(
  original_lines,
  replacement,
  is_insert,
  is_replace,
  orig_line_start,
  orig_line_end
)
  local start_line, end_line = orig_line_start - 1, orig_line_end - 1
  local start_char, end_char = 0, 0
  if is_replace then
    -- If we're replacing text, see if we can avoid replacing the entire line
    start_char = common_prefix_len(original_lines[orig_line_start], replacement[1])
    if start_char > 0 then
      replacement[1] = replacement[1]:sub(start_char + 1)
    end

    if original_lines[orig_line_end] then
      local last_line = replacement[#replacement]
      local suffix = common_suffix_len(original_lines[orig_line_end], last_line)
      -- If we're only replacing one line, make sure the prefix/suffix calculations don't overlap
      if orig_line_end == orig_line_start then
        suffix = math.min(suffix, original_lines[orig_line_end]:len() - start_char)
      end
      end_char = original_lines[orig_line_end]:len() - suffix
      if suffix > 0 then
        replacement[#replacement] = last_line:sub(1, last_line:len() - suffix)
      end
    end
  end
  -- If we're inserting text, make sure the text includes a newline at the end.
  -- The one exception is if we're inserting at the end of the file, in which case the newline is
  -- implicit
  if is_insert and start_line < #original_lines then
    table.insert(replacement, "")
  end
  local new_text = table.concat(replacement, "\n")

  return {
    newText = new_text,
    range = {
      start = {
        line = start_line,
        character = start_char,
      },
      ["end"] = {
        line = end_line,
        character = end_char,
      },
    },
  }
end

---@param bufnr integer
---@param original_lines string[]
---@param new_lines string[]
---@param range? conform.Range
---@param only_apply_range boolean
---@return lsp.TextEdit[]?
function M.as_text_edits(bufnr, original_lines, new_lines, range, only_apply_range)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  log.trace("Applying formatting to %s", bufname)
  -- The vim.diff algorithm doesn't handle changes in newline-at-end-of-file well. The unified
  -- result_type has some text to indicate that the eol changed, but the indices result_type has no
  -- such indication. To work around this, we just add a trailing newline to the end of both the old
  -- and the new text.
  table.insert(original_lines, "")
  table.insert(new_lines, "")
  local original_text = table.concat(original_lines, "\n")
  local new_text = table.concat(new_lines, "\n")
  table.remove(original_lines)
  table.remove(new_lines)

  -- Abort if output is empty but input is not (i.e. has some non-whitespace characters).
  -- This is to hack around oddly behaving formatters (e.g black outputs nothing for excluded files).
  if new_text:match("^%s*$") and not original_text:match("^%s*$") then
    log.warn("Aborting because a formatter returned empty output for buffer %s", bufname)
    return
  end

  log.trace("Comparing lines %s and %s", original_lines, new_lines)
  local indices = vim.diff(original_text, new_text, {
    result_type = "indices",
    algorithm = "histogram",
  })
  assert(indices)
  log.trace("Diff indices %s", indices)
  local text_edits = {}
  for _, idx in ipairs(indices) do
    local orig_line_start, orig_line_count, new_line_start, new_line_count = unpack(idx)
    local is_insert = orig_line_count == 0
    local is_delete = new_line_count == 0
    local is_replace = not is_insert and not is_delete
    local orig_line_end = orig_line_start + orig_line_count
    local new_line_end = new_line_start + new_line_count

    if is_insert then
      -- When the diff is an insert, it actually means to insert after the mentioned line
      orig_line_start = orig_line_start + 1
      orig_line_end = orig_line_end + 1
    end

    local replacement =
      require("conform.util").tbl_slice(new_lines, new_line_start, new_line_end - 1)

    -- For replacement edits, convert the end line to be inclusive
    if is_replace then
      orig_line_end = orig_line_end - 1
    end
    local should_apply_diff = not only_apply_range
      or not range
      or indices_in_range(range, orig_line_start, orig_line_end)
    if should_apply_diff then
      local text_edit = create_text_edit(
        original_lines,
        replacement,
        is_insert,
        is_replace,
        orig_line_start,
        orig_line_end
      )
      table.insert(text_edits, text_edit)

      -- If we're using the aftermarket range formatting, diffs often have paired delete/insert
      -- diffs. We should make sure that if one of them overlaps our selected range, extend the
      -- range so that we pick up the other diff as well.
      if range and only_apply_range then
        range = vim.deepcopy(range)
        range["end"][1] = math.max(range["end"][1], orig_line_end + 1)
      end
    end
  end

  return text_edits
end

--- Split text edits into more text edits using minimal diffs
--- TODO: support any TextEdits, currently only splits a single text edit that covers whole buffer
---@param text_edits lsp.TextEdit[]
---@param bufnr integer
---@return lsp.TextEdit[]
function M.diff_text_edits(text_edits, bufnr)
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
    text_edits = M.as_text_edits(bufnr, original_lines, new_lines, nil, false) or text_edits
  end
  return text_edits
end

--- Apply M.diff_text_edits to all TextEdits in WorkspaceEdit
---@param workspace_edit lsp.WorkspaceEdit
function M.diff_workspace_edit(workspace_edit)
  for uri, text_edits in pairs(workspace_edit.changes or {}) do
    local bufnr = vim.uri_to_bufnr(uri)
    workspace_edit.changes[uri] = M.diff_text_edits(text_edits, bufnr)
  end

  local lost_annotations = 0

  for _, change in ipairs(workspace_edit.documentChanges or {}) do
    if not change.kind then -- ignore create/rename/delete file, only TextDocumentEdit
      local doc_edit = change --[[@as lsp.TextDocumentEdit]]
      local bufnr = vim.uri_to_bufnr(doc_edit.textDocument.uri)

      -- TODO: handle ids of AnnotatedTextEdit when generating edits in diff_text_edits
      local initial_edits_count = #doc_edit.edits
      local annotation_ids = {}
      local annotations_count = 0
      for i, edit in ipairs(doc_edit.edits) do
        if edit.annotationId then
          annotation_ids[i] = edit.annotationId
          annotations_count = annotations_count + 1
        end
      end

      local new_edits = M.diff_text_edits(doc_edit.edits, bufnr)
      doc_edit.edits = new_edits

      -- Try to restore annotationId for edits if it's trivial
      if #doc_edit.edits == initial_edits_count then
        for i, edit in ipairs(doc_edit.edits) do
          edit.annotationId = annotation_ids[i]
        end
      elseif #doc_edit.edits == annotations_count then
        local edit_id = 1
        for i = 1, initial_edits_count do
          if annotation_ids[i] then
            doc_edit.edits[edit_id] = annotation_ids[i]
            edit_id = edit_id + 1
          end
        end
      else
        lost_annotations = lost_annotations + annotations_count
      end
    end
  end

  if lost_annotations > 0 then
    log.warn("Lost %d annotations from LSP WorkspaceEdit AnnotatedTextEdits", lost_annotations)
  end
end

--- Wrap an LSP textDocument/rename handler to split WorkspaceEdit into minimal diffs
---@param rename_handler fun(err?: table, result?: lsp.WorkspaceEdit, ctx: lsp.HandlerContext, config: table)
---@return fun(err?: table, result?: lsp.WorkspaceEdit, ctx: lsp.HandlerContext, config: table)
function M.wrap_rename_handler(rename_handler)
  return function(err, result, ctx, config)
    if result then
      M.diff_workspace_edit(result)
    end
    return rename_handler(err, result, ctx, config)
  end
end

return M
