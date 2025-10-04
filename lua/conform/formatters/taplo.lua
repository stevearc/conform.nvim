---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/tamasfe/taplo",
    description = "A TOML toolkit written in Rust.",
  },
  command = "taplo",
  args = function()
    ---@type lsp.LSPObject?
    local taplo_config = vim.tbl_get(vim.lsp.config, "taplo", "settings", "formatter")

    local ret = { "format" }
    if taplo_config ~= nil then
      for k, v in pairs(taplo_config) do
        vim.list_extend(ret, { "-o", ("%s=%s"):format(k, v) })
      end
    end
    vim.list_extend(ret, { "--stdin-filepath", "$FILENAME", "-" })

    return ret
  end,
}
