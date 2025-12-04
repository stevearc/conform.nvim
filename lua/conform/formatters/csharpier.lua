local is_local_cache = nil

--- Verify if csharpier is installed locally.
---@return boolean
local function is_local()
  if is_local_cache == nil then
    if vim.fn.executable("dotnet") == 0 then
      -- if dotnet itself is not available, assume the csharpier executable
      is_local_cache = false
    else
      local version_check = vim.system({ "dotnet", "csharpier", "--version" }):wait()
      is_local_cache = version_check.code == 0
    end
  end
  return is_local_cache
end

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/belav/csharpier",
    description = "The opinionated C# code formatter.",
  },
  command = function()
    if is_local() then
      return "dotnet"
    else
      return "csharpier"
    end
  end,
  args = function()
    if is_local() then
      return { "csharpier", "format", "--stdin-path", "$FILENAME" }
    else
      return { "format" }
    end
  end,
  stdin = true,
}
