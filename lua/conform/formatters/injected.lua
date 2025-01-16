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
    parser:parse(true)
    local root_lang = parser:lang()
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
        local surrounding = remove_surrounding(input_lines, buf_lang)
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
        conform.format_lines(formatter_names, input_lines, format_opts, function(err, new_lines)
          log.trace("Injected %s:%d:%d formatted lines %s", lang, start_lnum, end_lnum, new_lines)
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
