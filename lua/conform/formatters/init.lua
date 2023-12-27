local M = {}
local uv = vim.uv or vim.loop

---@private
---This is used for documentation generation
M.list_all_formatters = function()
  local ret = {}
  for path in vim.gsplit(vim.o.runtimepath, ",", { plain = true }) do
    local formatter_path = path .. "/lua/conform/formatters"
    local formatter_dir = uv.fs_opendir(formatter_path)
    if formatter_dir then
      local entries = uv.fs_readdir(formatter_dir)
      while entries do
        for _, entry in ipairs(entries) do
          if entry.name ~= "init.lua" then
            local basename = string.match(entry.name, "^(.*)%.lua$")
            local module = require("conform.formatters." .. basename)
            local module_data = vim.deepcopy(module.meta)
            module_data.has_options = module.options ~= nil
            ret[basename] = module_data
          end
        end
        entries = uv.fs_readdir(formatter_dir)
      end
      uv.fs_closedir(formatter_dir)
    end
  end
  return ret
end

-- A little metatable magic to allow accessing formatters like
-- require("conform.formatters").prettier
return setmetatable(M, {
  __index = function(_, k)
    return require("conform.formatters." .. k)
  end,
})
