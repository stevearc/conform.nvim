local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/Riverside-Healthcare/djLint",
    description = "✨ HTML Template Linter and Formatter. Django - Jinja - Nunjucks - Handlebars - GoLang.",
  },
  command = "djlint",
  args = function(_, ctx)
    return { "--reformat", "--indent", ctx.shiftwidth, "-" }
  end,
  cwd = util.root_file({
    ".djlintrc",
  }),
}
