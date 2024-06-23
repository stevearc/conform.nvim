local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/Riverside-Healthcare/djLint",
    description = "✨ HTML Template Linter and Formatter. Django - Jinja - Nunjucks - Handlebars - GoLang.",
  },
  command = "djlint",
  args = function(_, ctx)
    local indent = vim.bo[ctx.buf].tabstop or 4 -- default is 4
    return { "--reformat", "--indent", indent, "-" }
  end,
  cwd = util.root_file({
    ".djlintrc",
  }),
}
