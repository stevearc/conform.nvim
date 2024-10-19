local fs = require("conform.fs")
local util = require("conform.util")

local config_markers = {
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

--[[
-- Answers if a file under a specified file path contains specific vim pattern in the file content.
--
-- @param file path path to the file
-- @param regex regex pattern to match
--]]
local function file_contains_pattern(filePath, regex)
  if vim.fn.filereadable(filePath) == 1 then
    local lines = vim.fn.readfile(filePath)
    for _, line in ipairs(lines) do
      if vim.fn.match(line, regex) > -1 then
        return true
      end
    end
  end

  return false
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
  cwd = function(_, ctx)
    return util.root_file(function(name, path)
      if vim.tbl_contains(config_markers, name) then
        return true
      end
      --
      if name == "package.json" then
        local packageJsonPath = vim.fs.joinpath(path, name)

        return file_contains_pattern(packageJsonPath, '"prettier":\\s\\{-}{')
      end

      return false
    end)(_, ctx)
  end,
}
