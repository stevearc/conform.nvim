---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/Koihik/LuaFormatter",
    description = "Code formatter for Lua.",
  },
  command = "lua-format",
  args = { "-i", "$FILENAME" },
  stdin = false,
}
