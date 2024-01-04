local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/Riverside-Healthcare/djLint",
    description = "✨ HTML Template Linter and Formatter. Django - Jinja - Nunjucks - Handlebars - GoLang.",
  },
  command = "djlint",
  args = {
    "--reformat",
    "-",
  },
  cwd = util.root_file({
    ".djlintrc",
  }),
}
