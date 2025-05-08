local log = require("conform.log")

--- Validate that the `dotnet` runtime and the CSharpier global tool are present.
--- Logging errors if something is missing.
local function validate_dotnet()
  local has_dotnet = vim.fn.executable("dotnet")

  if not has_dotnet then
    log.error("dotnet is missing from path")
    return
  end

  vim.fn.system("dotnet csharpier --version")

  if vim.v.shell_error ~= 0 then
    log.error(
      "`dotnet csharpier --version` exited with a non 0 exit code, is it installed globally"
    )
  end
end

--- Get the command to execute for csharpier, when installed with mason it will be added to the nvim path.
--- If not installed with mason it is assumed to be installed as a dotnet tool.
---
--- Where the mason version will be prioritized over the dotnet version.
--- @return string
local function get_command()
  local in_path = vim.fn.executable("csharpier")

  if not in_path then
    validate_dotnet()
  end

  return in_path and "csharpier" or "dotnet csharpier"
end

--- Return the major version (1.x.x) as an integer of csharpier, as for version 1.0.0 the api has changed. So this
--- is used to preserve backwards compatibility.
--- @return integer
local function get_major_version(command)
  local version_out = vim.fn.system(command .. " --version")

  return tonumber((version_out or ""):match("^(%d+)")) or 0
end

local function build_args()
  local command = get_command()

  local major_version = get_major_version(command)

  local v1_api = major_version >= 1

  local args = v1_api and { "format", "$FILENAME", "--write-stdout" } or { "--write-stdout" }

  ---@type conform.FileFormatterConfig
  return {
    meta = {
      url = "https://github.com/belav/csharpier",
      description = "The opinionated C# code formatter.",
    },
    command = command,
    args = args,
    stdin = true,
    require_cwd = false,
  }
end

return build_args()
