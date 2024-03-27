-- This was renamed to clang-format
local conf = vim.deepcopy(require("conform.formatters.clang-format"))
conf.meta.deprecated = true
return conf
