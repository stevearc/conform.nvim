local COMMAND = "dotnet"
local TOOL = "csharpier"

--- Ask the system if csharpier is installed as dotnet tool
--- NOTE: prefer the cached variant
---@return boolean
local function is_local_long()
  if vim.fn.executable(COMMAND) == 0 then
    return false -- if dotnet itself is not available, assume the csharpier executable
  end

  local version_check = vim.system({ COMMAND, TOOL, "--version" }):wait()
  return version_check.code == 0 -- try calling dotnet tool
end

local is_local_cache = nil

--- Verify if csharpier is installed locally.
---@return boolean
local function is_local()
  if is_local_cache == nil then
    is_local_cache = is_local_long()
  end
  return is_local_cache
end

--- Get command favoring locally installed csharpier.
---@return string
local function get_command()
  if is_local() then
    return COMMAND
  end
  return TOOL
end

--- Get args favoring locally installed csharpier.
---@return string[]
local function get_args()
  local args = {}
  if is_local() then
    table.insert(args, TOOL)
  end
  table.insert(args, "format")
  return args
end

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/belav/csharpier",
    description = "The opinionated C# code formatter.",
  },
  command = get_command,
  args = get_args,
  stdin = true,
}
