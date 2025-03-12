---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/belav/csharpier",
    description = "The opinionated C# code formatter.",
  },
  command = "dotnet-csharpier",
  args = { "--write-stdout" },
  stdin = true,
}
