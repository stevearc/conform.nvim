---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/chipsalliance/verible/blob/master/verilog/tools/formatter/README.md",
    description = "The SystemVerilog formatter.",
  },
  command = "verible-verilog-format",
  args = { "--stdin_name", "$FILENAME", "-" },
}
