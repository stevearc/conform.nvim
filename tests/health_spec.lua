local conform = require("conform")
local test_util = require("tests.test_util")

describe("health", function()
  local get_clients = vim.lsp.get_clients
  after_each(function()
    vim.lsp.get_clients = get_clients
    test_util.reset_editor()
  end)

  it("applies the LSP filter from formatters_by_ft in ConformInfo", function()
    vim.lsp.get_clients = function()
      return { { id = 1, name = "lua_ls" }, { id = 2, name = "other_ls" } }
    end
    conform.formatters_by_ft.lua = {
      "stylua",
      filter = function(client)
        return client.name ~= "lua_ls"
      end,
    }
    vim.bo.filetype = "lua"
    require("conform.health").show_window()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    assert.truthy(vim.tbl_contains(lines, "LSP: other_ls"))
    assert.falsy(vim.tbl_contains(lines, "LSP: lua_ls, other_ls"))
  end)
end)
