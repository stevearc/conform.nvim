-- This was renamed to ruff_fix
local conf = vim.deepcopy(require("conform.formatters.ruff_fix"))
conf.meta.deprecated = true
return conf
