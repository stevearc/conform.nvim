---@param range? conform.Range
---@param start_lnum integer
---@param end_lnum integer
---@return boolean
local function in_range(range, start_lnum, end_lnum)
  return not range or (start_lnum <= range["end"][1] and range["start"][1] <= end_lnum)
end

---@param language? string
local function prefix_pattern(language)
  -- Handle markdown code blocks that are inside blockquotes
  -- > ```lua
  -- > local x = 1
  -- > ```
  return language == "markdown" and "^>?%s*" or "^%s*"
end

---@param lines string[]
---@param language? string The language of the buffer
---@return string?
local function get_indent(lines, language)
  local indent = nil
  local pattern = prefix_pattern(language)
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

---@param root_lang string
---@param lang string
---@return boolean
local function include_language_tree(root_lang, lang)
  -- We should not attempt to format html inside markdown
  -- See https://github.com/stevearc/conform.nvim/issues/485
  if root_lang == "markdown" and lang == "html" then
    return false
  end
  -- Don't format the root language with the injected formatter
  return root_lang ~= lang
end

---@class (exact) conform.Injected.Surrounding
---@field indent string?
---@field postfix string?

---Remove leading indentation from lines and return the indentation string
---@param lines string[]
---@param language? string The language of the buffer
---@return conform.Injected.Surrounding
local function remove_surrounding(lines, language)
  local surrounding = {}
  if lines[#lines]:match("^%s*$") then
    surrounding.postfix = lines[#lines]
    table.remove(lines)
  end

  local indent = get_indent(lines, language)
  if not indent then
    return surrounding
  end
  local sub_start = indent:len() + 1
  for i, line in ipairs(lines) do
    if line ~= "" then
      lines[i] = line:sub(sub_start)
    end
  end
  surrounding.indent = indent
  return surrounding
end

---@param lines string[]?
---@param surrounding conform.Injected.Surrounding
local function restore_surrounding(lines, surrounding)
  if not lines then
    return
  end

  local indent = surrounding.indent
  if indent then
    for i, line in ipairs(lines) do
      if line ~= "" then
        lines[i] = indent .. line
      end
    end
  end

  local postfix = surrounding.postfix
  if postfix then
    table.insert(lines, postfix)
  end
end

---@param placeholders string[]
---@param indent string?
local function remove_surrounding_from_placeholders(placeholders, indent)
  if not indent or #placeholders == 0 then
    return
  end
  local n = #indent
  for i, placeholder in ipairs(placeholders) do
    local lines = vim.split(placeholder, "\n", { plain = true, trimempty = false })
    for j, line in ipairs(lines) do
      if line ~= "" and line:sub(1, n) == indent then
        lines[j] = line:sub(n + 1)
      end
    end
    placeholders[i] = table.concat(lines, "\n")
  end
end

---Merge adjacent ranges that have the same language and share a prefix
---@param regions LangRange[]
---@param bufnr integer
---@param buf_lang? string
---@return LangRange[]
local function merge_ranges_with_prefix(regions, bufnr, buf_lang)
  local ret = {}

  local last_range = nil
  local accum = {}

  local function append_accum()
    if #accum == 0 then
      return
    end
    local lines = vim.api.nvim_buf_get_lines(bufnr, accum[1][2] - 1, accum[#accum][4], true)
    local prefix = get_indent(lines, buf_lang)
    if prefix then
      local new_range = {
        accum[1][1],
        accum[1][2],
        accum[1][3],
        accum[#accum][4],
        accum[#accum][5],
      }
      table.insert(ret, new_range)
    else
      vim.list_extend(ret, accum)
    end
    accum = {}
  end

  for _, range in ipairs(regions) do
    if not last_range or range[1] ~= last_range[1] or range[2] ~= last_range[4] then
      -- This is a new region entirely; new language, or not contiguous
      append_accum()
      accum = {}
    end
    table.insert(accum, range)
    last_range = range
  end
  append_accum()

  return ret
end

---@type table<string, vim.treesitter.Query|false>
local interpolation_queries = {}

---@param bufnr integer
---@param row integer 0-indexed
---@param col integer 0-indexed
---@return string
local function buf_char_at(bufnr, row, col)
  if col < 0 then
    return ""
  end
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, true)[1] or ""
  return line:sub(col + 1, col + 1)
end

---Some grammars (notably JS/TS) report the substitution node starting at `{` rather than `$`.
---@param bufnr integer
---@param row integer 0-indexed
---@param col integer 0-indexed
---@return integer
local function expand_interpolation_start(bufnr, row, col)
  if col > 0 and buf_char_at(bufnr, row, col - 1) == "$" then
    return col - 1
  end
  return col
end

---@param interpolation_query_strings table<string>
---@param lang string
---@return vim.treesitter.Query?
local function get_interpolation_query(interpolation_query_strings, lang)
  local qstr = interpolation_query_strings[lang]
  if not qstr then
    return nil
  end
  if interpolation_queries[lang] == nil then
    local ok, q = pcall(vim.treesitter.query.parse, lang, qstr)
    interpolation_queries[lang] = ok and q or false
  end
  return interpolation_queries[lang] or nil
end

---@param lines string[]?
---@param placeholders string[]
---@return string[]?
local function restore_interpolations(lines, placeholders)
  if not lines or #placeholders == 0 then
    return lines
  end
  local text = table.concat(lines, "\n")
  for i, placeholder in ipairs(placeholders) do
    local token = string.format("__CONFORM_INTERPOLATION_%d__", i)
    text = text:gsub(token, placeholder)
  end
  return vim.split(text, "\n", { plain = true, trimempty = false })
end

---@class (exact) InterpSpan
---@field sr integer
---@field sc integer
---@field er integer
---@field ec integer

---@param query vim.treesitter.Query
---@param root_node TSNode
---@param bufnr integer
---@return InterpSpan[]
local function collect_interpolation_spans(query, root_node, bufnr)
  local spans = {} ---@type InterpSpan[]
  for id, node in query:iter_captures(root_node, bufnr, 0, -1) do
    if query.captures[id] == "interp" then
      local sr, sc, er, ec = node:range()
      sc = expand_interpolation_start(bufnr, sr, sc)
      table.insert(spans, { sr = sr, sc = sc, er = er, ec = ec })
    end
  end
  table.sort(spans, function(a, b)
    if a.sr ~= b.sr then
      return a.sr < b.sr
    end
    return a.sc < b.sc
  end)
  return spans
end

---@param bufnr integer
---@param sr integer
---@param sc integer
---@param er integer
---@param ec integer
---@return string
local function get_buf_text_between(bufnr, sr, sc, er, ec)
  if sr == er then
    local line = vim.api.nvim_buf_get_lines(bufnr, sr, sr + 1, true)[1] or ""
    return line:sub(sc + 1, ec)
  end
  local lines = vim.api.nvim_buf_get_lines(bufnr, sr, er + 1, true)
  if #lines == 0 then
    return ""
  end
  lines[1] = (lines[1] or ""):sub(sc + 1)
  lines[#lines] = (lines[#lines] or ""):sub(1, ec)
  return table.concat(lines, "\n")
end

---@param bufnr integer
---@param interp_spans InterpSpan[]
---@param sr integer
---@param sc integer
---@param er integer
---@param ec integer
---@return boolean
local function gap_is_only_interpolations_and_whitespace(bufnr, interp_spans, sr, sc, er, ec)
  local gap_text = get_buf_text_between(bufnr, sr, sc, er, ec)
  if gap_text == "" then
    return false
  end

  -- Collect interpolation spans fully contained in the gap.
  ---@type {s: integer, e: integer}[]
  local contained = {}
  local gap_lines = vim.split(gap_text, "\n", { plain = true, trimempty = false })
  local line_offsets = { 0 }
  for i = 2, #gap_lines do
    line_offsets[i] = line_offsets[i - 1] + #gap_lines[i - 1] + 1
  end

  ---@param row integer
  ---@param col integer
  ---@return integer
  local function abs_idx(row, col)
    local line_idx = (row - sr) + 1
    if line_idx < 1 then
      return 1
    end
    if line_idx > #gap_lines then
      return #gap_text + 1
    end
    local rel_col = col
    if row == sr then
      rel_col = col - sc
    end
    return line_offsets[line_idx] + rel_col + 1
  end

  for _, span in ipairs(interp_spans) do
    local starts_in = span.sr > sr or (span.sr == sr and span.sc >= sc)
    local ends_in = span.er < er or (span.er == er and span.ec <= ec)
    if starts_in and ends_in then
      table.insert(contained, { s = abs_idx(span.sr, span.sc), e = abs_idx(span.er, span.ec) })
    end
  end

  if #contained == 0 then
    return false
  end

  table.sort(contained, function(a, b)
    return a.s > b.s
  end)
  for _, span in ipairs(contained) do
    gap_text = gap_text:sub(1, span.s - 1) .. gap_text:sub(span.e)
  end
  return gap_text:match("^%s*$") ~= nil
end

---@param regions LangRange[]
---@param bufnr integer
---@param interp_spans InterpSpan[]
---@return LangRange[]
local function merge_ranges_separated_by_interpolations(regions, bufnr, interp_spans)
  if #interp_spans == 0 then
    return regions
  end
  table.sort(regions, function(a, b)
    if a[2] ~= b[2] then
      return a[2] < b[2]
    end
    return a[3] < b[3]
  end)

  local merged = {} ---@type LangRange[]
  local cur = nil ---@type LangRange?
  for _, r in ipairs(regions) do
    if not cur then
      cur = vim.deepcopy(r)
    else
      local same_lang = cur[1] == r[1]
      local gap_ok = false
      if same_lang then
        local sr, sc = cur[4] - 1, cur[5]
        local er, ec = r[2] - 1, r[3]
        -- Only consider forward gaps
        if er > sr or (er == sr and ec >= sc) then
          gap_ok = gap_is_only_interpolations_and_whitespace(bufnr, interp_spans, sr, sc, er, ec)
        end
      end
      if same_lang and gap_ok then
        cur[4] = r[4]
        cur[5] = r[5]
      else
        table.insert(merged, cur)
        cur = vim.deepcopy(r)
      end
    end
  end
  if cur then
    table.insert(merged, cur)
  end
  return merged
end

---@param query vim.treesitter.Query
---@param root_node TSNode
---@param bufnr integer
---@param input_lines string[]
---@param region_start_row integer 0-indexed
---@param region_start_col integer 0-indexed
---@param region_end_row integer 0-indexed
---@param region_end_col integer 0-indexed
---@return string[] new_lines, string[] placeholders
local function protect_interpolations(
  query,
  root_node,
  bufnr,
  input_lines,
  region_start_row,
  region_start_col,
  region_end_row,
  region_end_col
)
  if #input_lines == 0 then
    return input_lines, {}
  end

  ---@type {sr: integer, sc: integer, er: integer, ec: integer, text: string}[]
  local spans = {}
  for id, node in query:iter_captures(root_node, bufnr, region_start_row, region_end_row + 1) do
    if query.captures[id] == "interp" then
      local sr, sc, er, ec = node:range()
      sc = expand_interpolation_start(bufnr, sr, sc)

      local starts_in = sr > region_start_row or (sr == region_start_row and sc >= region_start_col)
      local ends_in = er < region_end_row or (er == region_end_row and ec <= region_end_col)
      if starts_in and ends_in then
        local parts = vim.api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {})
        local text = table.concat(parts, "\n")
        if text ~= "" then
          table.insert(spans, { sr = sr, sc = sc, er = er, ec = ec, text = text })
        end
      end
    end
  end

  if #spans == 0 then
    return input_lines, {}
  end

  local function starts_before(a, b)
    if a.sr ~= b.sr then
      return a.sr < b.sr
    end
    return a.sc < b.sc
  end
  local function ends_after(a, b)
    if a.er ~= b.er then
      return a.er > b.er
    end
    return a.ec > b.ec
  end
  local function within(a, b)
    -- a is within b
    return (a.sr > b.sr or (a.sr == b.sr and a.sc >= b.sc))
      and (a.er < b.er or (a.er == b.er and a.ec <= b.ec))
  end

  -- Prefer outermost spans if the query returns nested captures.
  table.sort(spans, function(a, b)
    if starts_before(a, b) then
      return true
    elseif starts_before(b, a) then
      return false
    end
    return ends_after(a, b)
  end)

  local filtered = {} ---@type typeof(spans)
  local cur = nil ---@type {sr: integer, sc: integer, er: integer, ec: integer}?
  for _, span in ipairs(spans) do
    if not cur or not within(span, cur) then
      table.insert(filtered, span)
      cur = { sr = span.sr, sc = span.sc, er = span.er, ec = span.ec }
    end
  end

  -- Replace from the end so earlier positions stay valid.
  table.sort(filtered, function(a, b)
    if a.sr ~= b.sr then
      return a.sr > b.sr
    end
    return a.sc > b.sc
  end)

  local placeholders = {} ---@type string[]

  ---@param row integer 0-indexed
  ---@param col integer 0-indexed
  ---@return integer
  local function rel_col(row, col)
    if row == region_start_row then
      return col - region_start_col
    end
    return col
  end

  for _, span in ipairs(filtered) do
    table.insert(placeholders, span.text)
    local token = string.format("__CONFORM_INTERPOLATION_%d__", #placeholders)

    local rel_sr = (span.sr - region_start_row) + 1
    local rel_er = (span.er - region_start_row) + 1
    local rel_sc = rel_col(span.sr, span.sc)
    local rel_ec = rel_col(span.er, span.ec)

    local start_line = input_lines[rel_sr] or ""
    local end_line = input_lines[rel_er] or ""
    local prefix = start_line:sub(1, rel_sc)
    local suffix = end_line:sub(rel_ec + 1)

    input_lines[rel_sr] = prefix .. token .. suffix
    -- Collapse the spanned lines into the start line so restoring the placeholder's
    -- embedded newlines doesn't duplicate newlines from the lines array.
    for i = rel_er, rel_sr + 1, -1 do
      table.remove(input_lines, i)
    end
  end

  return input_lines, placeholders
end

---@class (exact) LangRange
---@field [1] string language
---@field [2] integer start lnum
---@field [3] integer start col
---@field [4] integer end lnum
---@field [5] integer end col

---@param ranges LangRange[]
---@param range LangRange
local function accum_range(ranges, range)
  local last_range = ranges[#ranges]
  if last_range then
    if last_range[1] == range[1] and last_range[4] == range[2] and last_range[5] == range[3] then
      last_range[4] = range[4]
      last_range[5] = range[5]
      return
    end
  end
  table.insert(ranges, range)
end

---@class (exact) conform.InjectedFormatterOptions
---@field ignore_errors boolean
---@field lang_to_ext table<string, string>
---@field lang_to_ft table<string, string>
---@field lang_to_formatters table<string, conform.FiletypeFormatter>
---@field interpolation_queries table<string, string>

---@type conform.FileLuaFormatterConfig
return {
  meta = {
    url = "doc/advanced_topics.md#injected-language-formatting-code-blocks",
    description = "Format treesitter injected languages.",
  },
  ---@type conform.InjectedFormatterOptions
  options = {
    -- Set to true to ignore errors
    ignore_errors = false,
    -- Map of treesitter language to filetype
    lang_to_ft = {
      bash = "sh",
    },
    -- Map of treesitter language to file extension
    -- A temporary file name with this extension will be generated during formatting
    -- because some formatters care about the filename.
    lang_to_ext = {
      bash = "sh",
      c_sharp = "cs",
      elixir = "exs",
      javascript = "js",
      julia = "jl",
      latex = "tex",
      markdown = "md",
      python = "py",
      ruby = "rb",
      rust = "rs",
      teal = "tl",
      typescript = "ts",
    },
    interpolation_queries = {
      -- Nix strings can contain `${ ... }` interpolations.
      nix = "(interpolation) @interp",
      -- JS/TS template strings contain `${ ... }` substitutions.
      javascript = "(template_substitution) @interp",
      typescript = "(template_substitution) @interp",
      jsx = "(template_substitution) @interp",
      tsx = "(template_substitution) @interp",
    },
    -- Map of treesitter language to formatters to use
    -- (defaults to the value from formatters_by_ft)
    lang_to_formatters = {},
  },
  condition = function(self, ctx)
    local buf_lang = vim.treesitter.language.get_lang(vim.bo[ctx.buf].filetype)
    local ok = pcall(vim.treesitter.get_string_parser, "", buf_lang)
    return ok
  end,
  format = function(self, ctx, lines, callback)
    local conform = require("conform")
    local errors = require("conform.errors")
    local log = require("conform.log")
    local util = require("conform.util")
    -- Need to add a trailing newline; some parsers need this.
    -- For example, if a markdown code block ends at the end of the file, a trailing newline is
    -- required otherwise the ``` will be grabbed as part of the injected block
    local text = table.concat(lines, "\n") .. "\n"
    local buf_lang = vim.treesitter.language.get_lang(vim.bo[ctx.buf].filetype)
    local ok, parser = pcall(vim.treesitter.get_string_parser, text, buf_lang)
    if not ok then
      callback("No treesitter parser for buffer")
      return
    end
    local options = self.options
    ---@cast options conform.InjectedFormatterOptions

    ---@param lang string
    ---@return nil|conform.FiletypeFormatter
    local function get_formatters(lang)
      local ft = options.lang_to_ft[lang] or lang
      return options.lang_to_formatters[ft] or conform.formatters_by_ft[ft]
    end

    --- Disable diagnostic to pass the typecheck github action
    --- This is available on nightly, but not on stable
    --- Stable doesn't have any parameters, so it's safe
    ---@diagnostic disable-next-line: redundant-parameter
    local trees = parser:parse(true)
    local root_lang = parser:lang()
    local root_tree = trees and trees[1] or nil
    local root_node = root_tree and root_tree:root() or nil
    local interpolation_query = root_node
        and get_interpolation_query(options.interpolation_queries, root_lang)
      or nil
    local interpolation_spans = (interpolation_query and root_node)
        and collect_interpolation_spans(interpolation_query, root_node, ctx.buf)
      or {}
    ---@type LangRange[]
    local regions = {}

    for lang, lang_tree in pairs(parser:children()) do
      if include_language_tree(root_lang, lang) then
        for _, ranges in ipairs(lang_tree:included_regions()) do
          for _, region in ipairs(ranges) do
            local formatters = get_formatters(lang)
            if formatters == nil then
              log.info("No formatters found for injected treesitter language %s", lang)
            else
              -- The types are wrong. included_regions should be Range[][] not integer[][]
              ---@diagnostic disable-next-line: param-type-mismatch
              local start_row, start_col, _, end_row, end_col, _ = unpack(region)
              accum_range(regions, { lang, start_row + 1, start_col, end_row + 1, end_col })
            end
          end
        end
      end
    end

    if #interpolation_spans > 0 then
      regions = merge_ranges_separated_by_interpolations(regions, ctx.buf, interpolation_spans)
    end

    regions = merge_ranges_with_prefix(regions, ctx.buf, buf_lang)

    if ctx.range then
      regions = vim.tbl_filter(function(region)
        return in_range(ctx.range, region[2], region[4])
      end, regions)
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
        local start_lnum, start_col, end_lnum, end_col, new_lines = unpack(replacement)
        local prefix = formatted_lines[start_lnum]:sub(1, start_col)
        local suffix = formatted_lines[end_lnum]:sub(end_col + 1)
        new_lines[1] = prefix .. new_lines[1]
        new_lines[#new_lines] = new_lines[#new_lines] .. suffix
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
    local formatter_cb = function(err, idx, region, input_lines, new_lines)
      if err then
        format_error = errors.coalesce(format_error, err)
        replacements[idx] = err
      else
        -- If the original lines started/ended with a newline, preserve that newline.
        -- Many formatters will trim them, but they're important for the document structure.
        if input_lines[1] == "" and new_lines[1] ~= "" then
          table.insert(new_lines, 1, "")
        end
        if input_lines[#input_lines] == "" and new_lines[#new_lines] ~= "" then
          table.insert(new_lines, "")
        end
        replacements[idx] = { region[2], region[3], region[4], region[5], new_lines }
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
    for i, region in ipairs(regions) do
      local lang = region[1]
      local start_lnum = region[2]
      local start_col = region[3]
      local end_lnum = region[4]
      local end_col = region[5]
      -- Ignore regions that overlap (contain) other regions
      if end_lnum < last_start_lnum then
        num_format = num_format + 1
        last_start_lnum = start_lnum
        local input_lines = util.tbl_slice(lines, start_lnum, end_lnum)
        input_lines[#input_lines] = input_lines[#input_lines]:sub(1, end_col)
        if start_col > 0 then
          local prefix = input_lines[1]:sub(0, start_col)
          if prefix:match(prefix_pattern(buf_lang)) == prefix then
            -- The first line in the range doesn't start at col 0, but the text on that line before
            -- it is just indentation nothing semantic.
            -- Update the range to include the indentation so that remove_surrounding() below can
            -- consider it as part of the indentation for the entire block.
            region[3] = 0
          else
            input_lines[1] = input_lines[1]:sub(start_col + 1)
          end
        end
        local ft_formatters = assert(get_formatters(lang))
        ---@type string[]
        local formatter_names
        if type(ft_formatters) == "function" then
          ft_formatters = ft_formatters(ctx.buf)
        end
        local stop_after_first = ft_formatters.stop_after_first
        if stop_after_first == nil then
          stop_after_first = conform.default_format_opts.stop_after_first
        end
        if stop_after_first == nil then
          stop_after_first = false
        end

        local formatters =
          conform.resolve_formatters(ft_formatters, ctx.buf, false, stop_after_first)
        formatter_names = vim.tbl_map(function(f)
          return f.name
        end, formatters)
        local idx = num_format
        log.debug("Injected format %s:%d:%d: %s", lang, start_lnum, end_lnum, formatter_names)
        log.trace("Injected format lines %s", input_lines)

        -- If the host language supports string interpolations that can appear inside injected
        -- blocks (e.g. nix `${...}`, JS/TS template substitutions), protect those nodes from the
        -- injected formatter and restore them afterwards.
        -- Important: this must run before remove_surrounding() so TreeSitter buffer coordinates
        -- still line up with the region text.
        local interpolation_placeholders = {}
        if interpolation_query and root_node and lang ~= root_lang then
          local rsr, rsc, rer, rec = start_lnum - 1, region[3], end_lnum - 1, end_col
          input_lines, interpolation_placeholders = protect_interpolations(
            interpolation_query,
            root_node,
            ctx.buf,
            input_lines,
            rsr,
            rsc,
            rer,
            rec
          )
        end

        local surrounding = remove_surrounding(input_lines, buf_lang)
        remove_surrounding_from_placeholders(interpolation_placeholders, surrounding.indent)
        -- Create a temporary buffer. This is only needed because some formatters rely on the file
        -- extension to determine a run mode (see https://github.com/stevearc/conform.nvim/issues/194)
        -- This is using lang_to_ext to map the language name to the file extension, and falls back
        -- to using the language name itself.
        local extension = options.lang_to_ext[lang] or lang
        local buf =
          vim.fn.bufadd(string.format("%s.%d.%s", vim.api.nvim_buf_get_name(ctx.buf), i, extension))
        vim.bo[buf].swapfile = false
        -- Actually load the buffer to set the buffer context which is required by some formatters such as `filetype`
        vim.fn.bufload(buf)
        tmp_bufs[buf] = true
        local format_opts = { async = true, bufnr = buf, quiet = true }
        log.trace(
          "Injected formatter input for %s (%s): %s",
          lang,
          table.concat(formatter_names, ","),
          table.concat(input_lines, "\\n")
        )
        conform.format_lines(formatter_names, input_lines, format_opts, function(err, new_lines)
          if err then
            log.error(
              "Error formatting injected language %s:%d:%d with formatters %s: %s",
              lang,
              start_lnum,
              end_lnum,
              formatter_names,
              err
            )
          end
          log.trace("Injected %s:%d:%d formatted lines %s", lang, start_lnum, end_lnum, new_lines)
          new_lines = restore_interpolations(new_lines, interpolation_placeholders)
          -- Preserve indentation in case the code block is indented
          restore_surrounding(new_lines, surrounding)
          vim.schedule_wrap(formatter_cb)(err, idx, region, input_lines, new_lines)
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
