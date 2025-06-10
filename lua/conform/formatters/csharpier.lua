local COMMAND = "dotnet"
local TOOL = "csharpier"
local cache = nil -- For performance

--- Verify if csharpier is installed locally.
---@return boolean
local function is_local()
  if cache == nil then
    local obj = vim.system({ COMMAND, TOOL, "--version" }):wait()
    cache = obj.code == 0
  end
  return cache
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
