---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/Koihik/LuaFormatter",
    description = "Reformats your Lua source code.",
  },
  command = "lua-format",
  args = { "-i", "$FILENAME" },
  stdin = false,
  cwd = require("conform.util").root_file({
    ".lua-format",
  }),
}
