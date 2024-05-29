---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/nvim-treesitter/nvim-treesitter/blob/main/CONTRIBUTING.md#formatting",
    description = "Tree-sitter query formatter",
  },
  condition = function()
    local ok, _ = pcall(vim.treesitter.language.inspect("query"))

    return ok or vim.api.nvim_get_runtime_file("scripts/format-queries.lua", false)[1] ~= nil
  end,
  command = "nvim",
  args = function()
    local args = { "-l" }
    local exe = vim.api.nvim_get_runtime_file("scripts/format-queries.lua", false)[1]

    table.insert(args, exe)
    table.insert(args, "$FILENAME")

    return args
  end,
  stdin = false,
}
