---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/builtins/formatting/trim_newlines.lua",
    description = "Trim new lines",
  },
  command = "awk",
  args = { 'NF{print s $0; s=""; next} {s=s ORS}' },
}
