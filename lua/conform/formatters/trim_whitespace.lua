---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/builtins/formatting/trim_whitespace.lua",
    description = "Trim whitespace",
  },
  command = "awk",
  args = { '{ sub(/[ \t]+$/, ""); print }' },
}
