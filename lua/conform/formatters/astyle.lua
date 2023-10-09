local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://astyle.sourceforge.net/astyle.html",
    description = "A Free, Fast, and Small Automatic Formatter for C, C++, C++/CLI, Objective-C, C#, and Java Source Code.",
  },
  command = "astyle",
  args = { "--quiet" },
  cwd = util.root_file({
    ".astylerc",
    "_astylerc",
  }),
}
