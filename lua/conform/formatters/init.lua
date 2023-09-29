local M = {}

-- A little metatable magic to allow accessing formatters like
-- require("conform.formatters").prettier
return setmetatable(M, {
  __index = function(_, k)
    return require("conform.formatters." .. k)
  end,
})
