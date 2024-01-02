---@type conform.FileFormatterConfig
return {
  meta = {
    url = "http://xmlsoft.org/xmllint.html",
    description = "Despite the name, xmllint can be used to format XML files as well as lint them.",
  },
  command = "xmllint",
  args = { "--format", "-" },
}
