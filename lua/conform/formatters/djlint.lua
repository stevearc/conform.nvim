local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/Riverside-Healthcare/djLint",
    description = "✨ HTML Template Linter and Formatter. Django - Jinja - Nunjucks - Handlebars - GoLang.",
  },
  command = "djlint",
  args = function(_, ctx)
    local bo = vim.bo[ctx.buf]
    local indent_size = bo.shiftwidth
    if indent_size == 0 or not indent_size then
      indent_size = bo.tabstop or 4 -- default is 4
    end
    return { "--reformat", "--indent", indent_size, "-" }
  end,
  cwd = util.root_file({
    ".djlintrc",
  }),
}
