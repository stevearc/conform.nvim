require("plenary.async").tests.add_to_env()
local conform = require("conform")
local injected = require("conform.formatters.injected")
local runner = require("conform.runner")
local test_util = require("tests.test_util")

-- injected formatter only supported on neovim 0.9+
if vim.fn.has("nvim-0.9") == 0 then
  return
end

---@param dir string
---@return string[]
local function list_test_files(dir)
  ---@diagnostic disable-next-line: param-type-mismatch
  local fd = vim.loop.fs_opendir(dir, nil, 32)
  ---@diagnostic disable-next-line: param-type-mismatch
  local entries = vim.loop.fs_readdir(fd)
  local ret = {}
  while entries do
    for _, entry in ipairs(entries) do
      if entry.type == "file" and not vim.endswith(entry.name, ".formatted") then
        table.insert(ret, entry.name)
      end
    end
    ---@diagnostic disable-next-line: param-type-mismatch
    entries = vim.loop.fs_readdir(fd)
  end
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.loop.fs_closedir(fd)
  return ret
end

describe("injected formatter", function()
  before_each(function()
    -- require("conform.log").level = vim.log.levels.TRACE
    conform.formatters_by_ft = {
      lua = { "test_mark" },
      html = { "test_mark" },
    }
    -- A test formatter that bookends lines with "|" so we can check what was passed in
    conform.formatters.test_mark = {
      format = function(self, ctx, lines, callback)
        local ret = {}
        for i, line in ipairs(lines) do
          if i == 1 and line == "" then
            -- Simulate formatters removing starting newline
          elseif i == #lines and line == "" then
            -- Simulate formatters removing trailing newline
          else
            table.insert(ret, "|" .. line .. "|")
          end
        end
        callback(nil, ret)
      end,
    }
  end)

  after_each(function()
    test_util.reset_editor()
  end)

  for _, filename in ipairs(list_test_files("tests/injected")) do
    local filepath = "./tests/injected/" .. filename
    local formatted_file = filepath .. ".formatted"
    it(filename, function()
      local bufnr = vim.fn.bufadd(filepath)
      vim.fn.bufload(bufnr)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
      local config = assert(conform.get_formatter_config("injected", bufnr))
      local ctx = runner.build_context(bufnr, config)
      local err, new_lines, done
      injected.format(injected, ctx, lines, function(e, formatted)
        done = true
        err = e
        new_lines = formatted
      end)
      vim.wait(1000, function()
        return done
      end)
      assert(err == nil, err)
      local expected_bufnr = vim.fn.bufadd(formatted_file)
      vim.fn.bufload(expected_bufnr)
      local expected_lines = vim.api.nvim_buf_get_lines(expected_bufnr, 0, -1, true)
      assert.are.same(expected_lines, new_lines)
    end)
  end
end)
