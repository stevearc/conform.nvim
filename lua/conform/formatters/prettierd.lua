local fs = require("conform.fs")
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
    error("Unable to open file " .. file)
  end

  local file_content = f:read("*all") -- Read entire file contents
  f:close()

  local ok, json = pcall(function()
    return vim.json.decode(file_content)
  end)

  if not ok then
    local log = require("conform.log")
    log.error("Unable to parse json file " .. file)

    return nil
  end

  return json
end

-- TODO: share this with "lua/conform/formatters/prettier.lua"
local cwd = function(self, ctx)
  return vim.fs.root(ctx.dirname, function(name, path)
    if vim.tbl_contains(config_file_names, name) then
      return true
    end

    if name == "package.json" then
      local packageJsonPath = vim.fs.joinpath(path, name)

      local packageJson = read_json(packageJsonPath)

      return packageJson and packageJson.prettier and true or false
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
