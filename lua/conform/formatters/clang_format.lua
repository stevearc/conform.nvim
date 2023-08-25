---@type conform.FormatterConfig
return {
  meta = {
    url = "https://www.kernel.org/doc/html/latest/process/clang-format.html",
    description = "Tool to format C/C++/… code according to a set of rules and heuristics.",
  },
  command = "clang-format",
  args = { "-assume-filename", "$FILENAME" },
}
