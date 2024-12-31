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
    return ok and pcall(require, "nvim-treesitter") and get_format_script() ~= nil
  end,
  command = "nvim",
  args = function()
    local script = get_format_script()
    assert(script)
    -- Manually set the runtimepath to put nvim-treesitter first. The format-queries script relies
    -- on the nvim-treesitter parser; the one bundled with Neovim may be outdated.
    local rtp = vim.fn.fnamemodify(script, ":h:h")
    return { "-c", "set rtp^=" .. rtp, "-l", script, "$FILENAME" }
  end,
  stdin = false,
}
