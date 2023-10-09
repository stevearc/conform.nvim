require("plenary.async").tests.add_to_env()
local conform = require("conform")
local test_util = require("tests.test_util")

describe("api", function()
  after_each(function()
    test_util.reset_editor()
  end)

  it("retrieves info about a formatter", function()
    local info = conform.get_formatter_info("stylua")
    assert.equal("stylua", info.name)
    assert.equal("stylua", info.command)
    assert.equal("boolean", type(info.available))
  end)

  it("retrieves unavailable info if formatter does not exist", function()
    local info = conform.get_formatter_info("asdf")
    assert.equal("asdf", info.name)
    assert.equal("asdf", info.command)
    assert.falsy(info.available)
  end)

  describe("list_formatters", function()
    local get_formatter_info = conform.get_formatter_info
    before_each(function()
      conform.get_formatter_info = function(...)
        local info = get_formatter_info(...)
        info.available = true
        return info
      end
    end)
    after_each(function()
      conform.get_formatter_info = get_formatter_info
    end)

    it("lists all formatters configured for buffer", function()
      conform.formatters_by_ft.lua = { "stylua", "lua-format" }
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(bufnr)
      vim.bo[bufnr].filetype = "lua"
      local formatters = conform.list_formatters()
      local formatter_names = vim.tbl_map(function(f)
        return f.name
      end, formatters)
      assert.are.same({ "stylua", "lua-format" }, formatter_names)
    end)

    it("merges formatters from mixed filetypes", function()
      conform.formatters_by_ft.lua = { "stylua", "lua-format" }
      conform.formatters_by_ft["*"] = { "trim_whitespace" }
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(bufnr)
      vim.bo[bufnr].filetype = "lua"
      local formatters = conform.list_formatters()
      local formatter_names = vim.tbl_map(function(f)
        return f.name
      end, formatters)
      assert.are.same({ "stylua", "lua-format", "trim_whitespace" }, formatter_names)
    end)

    it("flattens formatters in alternation groups", function()
      conform.formatters_by_ft.lua = { { "stylua", "lua-format" }, "trim_whitespace" }
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(bufnr)
      vim.bo[bufnr].filetype = "lua"
      local formatters = conform.list_formatters()
      local formatter_names = vim.tbl_map(function(f)
        return f.name
      end, formatters)
      assert.are.same({ "stylua", "trim_whitespace" }, formatter_names)
    end)
  end)

  describe("list_all_formatters", function()
    it("lists all formatters configured for all buffers", function()
      conform.formatters_by_ft.lua = { "stylua", "lua-format" }
      conform.formatters_by_ft["*"] = { "trim_whitespace" }
      local formatters = conform.list_all_formatters()
      local formatter_names = vim.tbl_map(function(f)
        return f.name
      end, formatters)
      table.sort(formatter_names)
      assert.are.same({ "lua-format", "stylua", "trim_whitespace" }, formatter_names)
    end)

    it("flattens formatters in alternation groups", function()
      conform.formatters_by_ft.lua = { { "stylua", "lua-format" } }
      conform.formatters_by_ft["*"] = { "trim_whitespace" }
      local formatters = conform.list_all_formatters()
      local formatter_names = vim.tbl_map(function(f)
        return f.name
      end, formatters)
      table.sort(formatter_names)
      assert.are.same({ "lua-format", "stylua", "trim_whitespace" }, formatter_names)
    end)
  end)
end)
