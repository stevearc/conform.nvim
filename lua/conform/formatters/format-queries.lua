---@return nil|string
local function get_format_script()
  return vim.api.nvim_get_runtime_file("scripts/format-queries.lua", false)[1]
end

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/nvim-treesitter/nvim-treesitter/blob/main/CONTRIBUTING.md#formatting",
    description = "Tree-sitter query formatter.",
  },
  condition = function()
    local ok = pcall(vim.treesitter.language.inspect, "query")
    return ok and get_format_script() ~= nil
  end,
  command = "nvim",
  args = function()
    return { "-l", get_format_script(), "$FILENAME" }
  end,
  stdin = false,
}
