---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/belav/csharpier",
    description = "The opinionated C# code formatter.",
  },
  command = "dotnet",
  args = { "csharpier", "format", "--write-stdout" },
  stdin = true,
}
