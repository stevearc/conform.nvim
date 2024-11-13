-- This was renamed to xmlformatter
local conf = vim.deepcopy(require("conform.formatters.xmlformatter"))
conf.meta.deprecated = true
return conf
