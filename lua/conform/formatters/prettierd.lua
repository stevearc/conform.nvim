local fs = require("conform.fs")
local log = require("conform.log")
local util = require("conform.util")

local config_file_names = {
  -- https://prettier.io/docs/en/configuration.html
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.json5",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  ".prettierrc.toml",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
}

---@param file string
---@return nil|table
local function read_json(file)
  local f = io.open(file, "r")
  if not f then
    log.error("Unable to open file %s", file)
    return nil
  end

  local file_content = f:read("*all") -- Read entire file contents
  f:close()

  local ok, json = pcall(vim.json.decode, file_content)
  if not ok then
    log.error("Unable to parse json file %s", file)
    return nil
  end

  return json
end

-- @param self conform.FormatterConfig
-- @param ctx conform.Context|conform.RangeContext
-- @return string|nil args the arguments for setting a `prettier` parser if they exist in the options, nil otherwise
local cwd = function(self, ctx)
  return vim.fs.root(ctx.dirname, function(name, path)
    if vim.tbl_contains(config_file_names, name) then
      return true
    end

    if name == "package.json" then
      local full_path = vim.fs.joinpath(path, name)
      local package_data = read_json(full_path)
      return package_data and package_data.prettier and true or false
    end

    return false
  end)
end

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/fsouza/prettierd",
    description = "prettier, as a daemon, for ludicrous formatting speed.",
  },
  command = util.from_node_modules(fs.is_windows and "prettierd.cmd" or "prettierd"),
  args = { "$FILENAME" },
  range_args = function(self, ctx)
    local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
    return { "$FILENAME", "--range-start=" .. start_offset, "--range-end=" .. end_offset }
  end,
  cwd = cwd,
}
