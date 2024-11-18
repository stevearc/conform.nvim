---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/ruby-syntax-tree/syntax_tree",
    description = "Syntax Tree is a suite of tools built on top of the internal CRuby parser.",
  },
  command = "stree",
  stdin = false,
  args = { "write", "$FILENAME" },
  cwd = require("conform.util").root_file({ ".streerc" }),
}
