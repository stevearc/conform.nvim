---@param range? conform.Range
---@param start_lnum integer
---@param end_lnum integer
---@return boolean
local function in_range(range, start_lnum, end_lnum)
  return not range or (start_lnum <= range["end"][1] and range["start"][1] <= end_lnum)
end

---@param lines string[]
---@param language? string The language of the buffer
---@return string?
local function get_indent(lines, language)
  local indent = nil
  -- Handle markdown code blocks that are inside blockquotes
  -- > ```lua
  -- > local x = 1
  -- > ```
  local pattern = language == "markdown" and "^>?%s*" or "^%s*"
  for _, line in ipairs(lines) do
    if line ~= "" then
      local whitespace = line:match(pattern)
      if whitespace == "" then
        return nil
      elseif not indent or whitespace:len() < indent:len() then
        indent = whitespace
      end
    end
  end
  return indent
end

---Remove leading indentation from lines and return the indentation string
---@param lines string[]
---@param language? string The language of the buffer
---@return string?
local function remove_indent(lines, language)
  local indent = get_indent(lines, language)
  if not indent then
    return
  end
  local sub_start = indent:len() + 1
  for i, line in ipairs(lines) do
    if line ~= "" then
      lines[i] = line:sub(sub_start)
    end
  end
  return indent
end

---@param lines string[]?
---@param indentation string?
local function apply_indent(lines, indentation)
  if not lines or not indentation then
    return
  end
  for i, line in ipairs(lines) do
    if line ~= "" then
      lines[i] = indentation .. line
    end
  end
end

---@class (exact) conform.InjectedFormatterOptions
---@field ignore_errors boolean

---@type conform.FileLuaFormatterConfig
return {
  meta = {
    url = "doc/advanced_topics.md#injected-language-formatting-code-blocks",
    description = "Format treesitter injected languages.",
  },
  options = {
    -- Set to true to ignore errors
    ignore_errors = false,
  },
  condition = function(self, ctx)
    local ok, parser = pcall(vim.treesitter.get_parser, ctx.buf)
    -- Require Neovim 0.9 because the treesitter API has changed significantly
    ---@diagnostic disable-next-line: invisible
    return ok and parser._injection_query and vim.fn.has("nvim-0.9") == 1
  end,
  format = function(self, ctx, lines, callback)
    local conform = require("conform")
    local errors = require("conform.errors")
    local log = require("conform.log")
    local util = require("conform.util")
    local text = table.concat(lines, "\n")
    local buf_lang = vim.treesitter.language.get_lang(vim.bo[ctx.buf].filetype)
    local ok, parser = pcall(vim.treesitter.get_string_parser, text, buf_lang)
    if not ok then
      callback("No treesitter parser for buffer")
      return
    end
    ---@type conform.InjectedFormatterOptions
    local options = self.options
    --- Disable diagnostic to pass the typecheck github action
    --- This is available on nightly, but not on stable
    --- Stable doesn't have any parameters, so it's safe to always pass `false`
    ---@diagnostic disable-next-line: redundant-parameter
    parser:parse(false)
    local root_lang = parser:lang()
    local regions = {}

    for _, tree in pairs(parser:trees()) do
      local root_node = tree:root()
      local start_line, _, end_line, _ = root_node:range()

      -- I don't like using these private methods, but critically we do _not_ want to format
      -- "combined" injections (they contain the metadata "injection.combined"). These injections
      -- will merge all of their regions into a single LanguageTree. If we then try to format the
      -- range defined by that LanguageTree, we will likely end up with a range that contains all
      -- sorts of content. As a concrete example, consider the following markdown:
      --   This is some text
      --   <!-- Here is a comment -->
      --   Some more text
      --   <!-- Another comment -->
      -- Since the html injection is combined, the range will contain "Some more text", which is not
      -- what we want.
      -- To avoid this, don't parse with injections. Instead, we use private methods to run the
      -- injection queries ourselves, and then filter out the combined injections.
      for _, match, metadata in
        ---@diagnostic disable-next-line: invisible
        parser._injection_query:iter_matches(root_node, text, start_line, end_line + 1)
      do
        ---@diagnostic disable-next-line: invisible
        local lang, combined, ranges = parser:_get_injection(match, metadata)
        local has_formatters = conform.formatters_by_ft[lang] ~= nil
        if lang and has_formatters and not combined and #ranges > 0 and lang ~= root_lang then
          local start_lnum
          local end_lnum
          -- Merge all of the ranges into a single range
          for _, range in ipairs(ranges) do
            if not start_lnum or start_lnum > range[1] + 1 then
              start_lnum = range[1] + 1
            end
            if not end_lnum or end_lnum < range[4] then
              end_lnum = range[4]
            end
          end
          if in_range(ctx.range, start_lnum, end_lnum) then
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
        -- Find all of the conform errors in the replacements table and remove them
        local i = 1
        while i <= #replacements do
          if replacements[i].code then
            table.remove(replacements, i)
          else
            i = i + 1
          end
        end
        if options.ignore_errors then
          format_error = nil
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
      callback(format_error, formatted_lines)
    end

    local num_format = 0
    local tmp_bufs = {}
    local formatter_cb = function(err, idx, start_lnum, end_lnum, new_lines)
      if err then
        format_error = errors.coalesce(format_error, err)
        replacements[idx] = err
      else
        replacements[idx] = { start_lnum, end_lnum, new_lines }
      end
      num_format = num_format - 1
      if num_format == 0 then
        for buf in pairs(tmp_bufs) do
          vim.api.nvim_buf_delete(buf, { force = true })
        end
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
        local ft_formatters = conform.formatters_by_ft[lang]
        ---@type string[]
        local formatter_names
        if type(ft_formatters) == "function" then
          formatter_names = ft_formatters(ctx.buf)
        else
          local formatters = require("conform").resolve_formatters(ft_formatters, ctx.buf, false)
          formatter_names = vim.tbl_map(function(f)
            return f.name
          end, formatters)
        end
        local idx = num_format
        log.debug("Injected format %s:%d:%d: %s", lang, start_lnum, end_lnum, formatter_names)
        log.trace("Injected format lines %s", input_lines)
        local indent = remove_indent(input_lines, buf_lang)
        -- Create a temporary buffer. This is only needed because some formatters rely on the file
        -- extension to determine a run mode (see https://github.com/stevearc/conform.nvim/issues/194)
        -- This is using the language name as the file extension, but that is a reasonable
        -- approximation for now. We can add special cases as the need arises.
        local buf = vim.fn.bufadd(string.format("%s.%s", vim.api.nvim_buf_get_name(ctx.buf), lang))
        -- Actually load the buffer to set the buffer context which is required by some formatters such as `filetype`
        vim.fn.bufload(buf)
        tmp_bufs[buf] = true
        local format_opts = { async = true, bufnr = buf, quiet = true }
        conform.format_lines(formatter_names, input_lines, format_opts, function(err, new_lines)
          -- Preserve indentation in case the code block is indented
          apply_indent(new_lines, indent)
          formatter_cb(err, idx, start_lnum, end_lnum, new_lines)
        end)
      end
    end
    if num_format == 0 then
      apply_format_results()
    end
  end,
  -- TODO this is kind of a hack. It's here to ensure all_support_range_formatting is set properly.
  -- Should figure out a better way to do this.
  range_args = true,
}
