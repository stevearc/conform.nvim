---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://beancount.github.io/docs/running_beancount_and_generating_reports.html#bean-format",
    description = "Reformat Beancount files to right-align all the numbers at the same, minimal column.",
  },
  command = "bean-format",
  args = {
    "-",
  },
}
