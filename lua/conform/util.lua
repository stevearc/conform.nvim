local M = {}

---Find a command in node_modules
---@param cmd string
---@return fun(ctx: conform.Context): string
M.from_node_modules = function(cmd)
  return M.find_executable({ "node_modules/.bin/" .. cmd }, cmd)
end

---Search parent directories for a relative path to a command
---@param paths string[]
---@param default string
---@return fun(self: conform.FormatterConfig, ctx: conform.Context): string
---@example
--- local cmd = require("conform.util").find_executable({ "node_modules/.bin/prettier" }, "prettier")
M.find_executable = function(paths, default)
  return function(self, ctx)
    for _, path in ipairs(paths) do
      local normpath = vim.fs.normalize(path)
      local is_absolute = vim.startswith(normpath, "/")
      if is_absolute and vim.fn.executable(normpath) then
        return normpath
      end

      local idx = normpath:find("/", 1, true)
      local dir, subpath
      if idx then
        dir = normpath:sub(1, idx - 1)
        subpath = normpath:sub(idx)
      else
        -- This is a bare relative-path executable
        dir = normpath
        subpath = ""
      end
      local results = vim.fs.find(dir, { upward = true, path = ctx.dirname, limit = math.huge })
      for _, result in ipairs(results) do
        local fullpath = result .. subpath
        if vim.fn.executable(fullpath) == 1 then
          return fullpath
        end
      end
    end

    return default
  end
end

---@param files string|string[]
---@return fun(self: conform.FormatterConfig, ctx: conform.Context): nil|string
M.root_file = function(files)
  return function(self, ctx)
    return vim.fs.root(ctx.dirname, files)
  end
end

---@param bufnr integer
---@param range conform.Range
---@return integer start_offset
---@return integer end_offset
M.get_offsets_from_range = function(bufnr, range)
  local row = range.start[1] - 1
  local end_row = range["end"][1] - 1
  local col = range.start[2]
  local end_col = range["end"][2]
  local start_offset = vim.api.nvim_buf_get_offset(bufnr, row) + col
  local end_offset = vim.api.nvim_buf_get_offset(bufnr, end_row) + end_col
  return start_offset, end_offset
end

---@generic T : any
---@param tbl T[]
---@param start_idx? number
---@param end_idx? number
---@return T[]
M.tbl_slice = function(tbl, start_idx, end_idx)
  local ret = {}
  if not start_idx then
    start_idx = 1
  end
  if not end_idx then
    end_idx = #tbl
  end
  for i = start_idx, end_idx do
    table.insert(ret, tbl[i])
  end
  return ret
end

---@generic T : fun()
---@param cb T
---@param wrapper T
---@return T
M.wrap_callback = function(cb, wrapper)
  return function(...)
    wrapper(...)
    cb(...)
  end
end

---Helper function to add to the default args of a formatter.
---@param args string|string[]|fun(self: conform.FormatterConfig, ctx: conform.Context): string|string[]
---@param extra_args string|string[]|fun(self: conform.FormatterConfig, ctx: conform.Context): string|string[]
---@param opts? { append?: boolean }
---@example
--- local util = require("conform.util")
--- local prettier = require("conform.formatters.prettier")
--- require("conform").formatters.prettier = vim.tbl_deep_extend("force", prettier, {
---   args = util.extend_args(prettier.args, { "--tab", "--indent", "2" }),
---   range_args = util.extend_args(prettier.range_args, { "--tab", "--indent", "2" }),
--- })
M.extend_args = function(args, extra_args, opts)
  opts = opts or {}
  return function(self, ctx)
    if type(args) == "function" then
      args = args(self, ctx)
    end
    if type(extra_args) == "function" then
      extra_args = extra_args(self, ctx)
    end
    if type(args) == "string" then
      if type(extra_args) ~= "string" then
        extra_args = table.concat(extra_args, " ")
      end
      if opts.append then
        return args .. " " .. extra_args
      else
        return extra_args .. " " .. args
      end
    else
      if type(extra_args) == "string" then
        error("extra_args must be a table when args is a table")
      end
      local ret = {}
      if opts.append then
        vim.list_extend(ret, args or {})
        vim.list_extend(ret, extra_args or {})
      else
        vim.list_extend(ret, extra_args or {})
        vim.list_extend(ret, args or {})
      end
      return ret
    end
  end
end

---@param formatter conform.FormatterConfig
---@param extra_args string|string[]|fun(self: conform.FormatterConfig, ctx: conform.Context): string|string[]
---@param opts? { append?: boolean }
---@example
--- local util = require("conform.util")
--- local prettier = require("conform.formatters.prettier")
--- util.add_formatter_args(prettier, { "--tab", "--indent", "2" })
M.add_formatter_args = function(formatter, extra_args, opts)
  formatter.args = M.extend_args(formatter.args, extra_args, opts)
  if formatter.range_args then
    formatter.range_args = M.extend_args(formatter.range_args, extra_args, opts)
  end
end

---@param config conform.FormatterConfig
---@param override conform.FormatterConfigOverride
---@return conform.FormatterConfig
M.merge_formatter_configs = function(config, override)
  local ret = vim.tbl_deep_extend("force", config, override)
  if override.prepend_args then
    M.add_formatter_args(ret, override.prepend_args, { append = false })
  elseif override.append_args then
    M.add_formatter_args(ret, override.append_args, { append = true })
  end
  return ret
end

---@param bufnr integer
---@return integer
M.buf_get_changedtick = function(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return -2
  end
  local changedtick = vim.b[bufnr].changedtick
  -- changedtick gets set to -1 when vim is exiting. We have an autocmd that should store it in
  -- last_changedtick before it is set to -1.
  if changedtick == -1 then
    return vim.b[bufnr].last_changedtick or -1
  else
    return changedtick
  end
end

---Parse the rust edition from the Cargo.toml file
---@param dir string
---@return string?
M.parse_rust_edition = function(dir)
  local manifest = vim.fs.find("Cargo.toml", { upward = true, path = dir })[1]
  if manifest then
    for line in io.lines(manifest) do
      if line:match("^edition *=") then
        local edition = line:match("%d+")
        if edition then
          return edition
        end
      end
    end
  end
end

---@param cmd string
---@return string[]
M.shell_build_argv = function(cmd)
  local argv = {}

  -- If the shell starts with a quote, it contains spaces (from :help 'shell').
  -- The shell may also have additional arguments in it, separated by spaces.
  if vim.startswith(vim.o.shell, '"') then
    local quoted = vim.o.shell:match('^"([^"]+)"')
    table.insert(argv, quoted)
    vim.list_extend(argv, vim.split(vim.o.shell:sub(quoted:len() + 3), "%s+", { trimempty = true }))
  else
    vim.list_extend(argv, vim.split(vim.o.shell, "%s+"))
  end

  vim.list_extend(argv, vim.split(vim.o.shellcmdflag, "%s+", { trimempty = true }))

  if vim.o.shellxquote ~= "" then
    -- When shellxquote is "(", we should escape the shellxescape characters with '^'
    -- See :help 'shellxescape'
    if vim.o.shellxquote == "(" and vim.o.shellxescape ~= "" then
      cmd = cmd:gsub(".", function(char)
        if string.find(vim.o.shellxescape, char, 1, true) then
          return "^" .. char
        else
          return char
        end
      end)
    end

    if vim.o.shellxquote == "(" then
      cmd = "(" .. cmd .. ")"
    elseif vim.o.shellxquote == '"(' then
      cmd = '"(' .. cmd .. ')"'
    else
      cmd = vim.o.shellxquote .. cmd .. vim.o.shellxquote
    end
  end

  table.insert(argv, cmd)
  return argv
end

---@param bufnr integer
---@return string
M.buf_line_ending = function(bufnr)
  local fileformat = vim.bo[bufnr].fileformat
  if fileformat == "dos" then
    return "\r\n"
  elseif fileformat == "mac" then
    return "\r"
  else
    return "\n"
  end
end

return M
