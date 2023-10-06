---@param range? conform.Range
---@param start_lnum integer
---@param end_lnum integer
---@return boolean
local function in_range(range, start_lnum, end_lnum)
  return not range or (start_lnum <= range["end"][1] and range["start"][1] <= end_lnum)
end

---@param lines string[]
---@return string?
local function get_indent(lines)
  local indent = nil
  for _, line in ipairs(lines) do
    if line ~= "" then
      local whitespace = line:match("^%s*")
      if whitespace == "" then
        return nil
      elseif not indent or whitespace:len() < indent:len() then
        indent = whitespace
      end
    end
  end
  return indent
end

---@param original_lines string[]
---@param new_lines? string[]
local function apply_indent(original_lines, new_lines)
  if not new_lines then
    return
  end
  local indent = get_indent(original_lines)
  local already_indented = get_indent(new_lines)
  if not indent or already_indented then
    return
  end
  for i, line in ipairs(new_lines) do
    if line ~= "" then
      new_lines[i] = indent .. line
    end
  end
end

---@class conform.InjectedFormatterConfig : conform.FileLuaFormatterConfig
---@field format fun(self: conform.InjectedFormatterConfig, ctx: conform.Context, lines: string[], callback: fun(err: nil|string, new_lines: nil|string[]))
---@field condition? fun(self: conform.InjectedFormatterConfig, ctx: conform.Context): boolean
---@field options conform.InjectedFormatterOptions

---@class (exact) conform.InjectedFormatterOptions
---@field ignore_errors boolean

---@type conform.InjectedFormatterConfig
return {
  meta = {
    url = "lua/conform/formatters/injected.lua",
    description = "Format treesitter injected languages.",
  },
  options = {
    -- Set to true to ignore errors
    ignore_errors = false,
  },
  condition = function(self, ctx)
    local ok = pcall(vim.treesitter.get_parser, ctx.buf)
    return ok
  end,
  format = function(self, ctx, lines, callback)
    local conform = require("conform")
    local log = require("conform.log")
    local util = require("conform.util")
    local text = table.concat(lines, "\n")
    local buf_lang = vim.treesitter.language.get_lang(vim.bo[ctx.buf].filetype)
    local ok, parser = pcall(vim.treesitter.get_string_parser, text, buf_lang)
    if not ok then
      callback("No treesitter parser for buffer")
      return
    end
    --- Disable diagnostic to pass the typecheck github action
    --- This is available on nightly, but not on stable
    --- Stable doesn't have any parameters, so it's safe to always pass `true`
    ---@diagnostic disable-next-line: redundant-parameter
    parser:parse(true)
    local root_lang = parser:lang()
    local regions = {}
    for lang, child_tree in pairs(parser:children()) do
      local formatter_names = conform.formatters_by_ft[lang]
      if formatter_names and lang ~= root_lang then
        for _, tree in ipairs(child_tree:trees()) do
          local root = tree:root()
          local start_lnum = root:start() + 1
          local end_lnum = root:end_()
          if start_lnum <= end_lnum and in_range(ctx.range, start_lnum, end_lnum) then
            table.insert(regions, { lang, start_lnum, end_lnum })
          end
        end
      end
    end
    -- Sort from largest start_lnum to smallest
    table.sort(regions, function(a, b)
      return a[2] > b[2]
    end)
    log.trace("Injected formatter regions %s", regions)

    local replacements = {}
    local format_error = nil

    local function apply_format_results()
      if format_error then
        if self.options.ignore_errors then
          -- Find all of the conform errors in the replacements table and remove them
          local i = 1
          while i <= #replacements do
            if replacements[i].code then
              table.remove(replacements, i)
            else
              i = i + 1
            end
          end
        else
          callback(format_error)
          return
        end
      end

      local formatted_lines = vim.deepcopy(lines)
      for _, replacement in ipairs(replacements) do
        local start_lnum, end_lnum, new_lines = unpack(replacement)
        for _ = start_lnum, end_lnum do
          table.remove(formatted_lines, start_lnum)
        end
        for i = #new_lines, 1, -1 do
          table.insert(formatted_lines, start_lnum, new_lines[i])
        end
      end
      callback(nil, formatted_lines)
    end

    local num_format = 0
    local formatter_cb = function(err, idx, start_lnum, end_lnum, new_lines)
      if err then
        format_error = err
        replacements[idx] = err
      else
        replacements[idx] = { start_lnum, end_lnum, new_lines }
      end
      num_format = num_format - 1
      if num_format == 0 then
        apply_format_results()
      end
    end
    local last_start_lnum = #lines + 1
    for _, region in ipairs(regions) do
      local lang, start_lnum, end_lnum = unpack(region)
      -- Ignore regions that overlap (contain) other regions
      if end_lnum < last_start_lnum then
        num_format = num_format + 1
        last_start_lnum = start_lnum
        local input_lines = util.tbl_slice(lines, start_lnum, end_lnum)
        local formatter_names = conform.formatters_by_ft[lang]
        local format_opts = { async = true, bufnr = ctx.buf, quiet = true }
        local idx = num_format
        log.debug("Injected format %s:%d:%d: %s", lang, start_lnum, end_lnum, formatter_names)
        log.trace("Injected format lines %s", input_lines)
        conform.format_lines(formatter_names, input_lines, format_opts, function(err, new_lines)
          -- Preserve indentation in case the code block is indented
          apply_indent(input_lines, new_lines)
          formatter_cb(err, idx, start_lnum, end_lnum, new_lines)
        end)
      end
    end
    if num_format == 0 then
      apply_format_results()
    end
  end,
}
