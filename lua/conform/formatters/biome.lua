local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/biomejs/biome",
    description = "A toolchain for web projects, aimed to provide functionalities to maintain them.",
  },
  command = util.from_node_modules("biome"),
  stdin = true,
  args = function(self, ctx)
    if self:cwd(ctx) then
      return { "format", "--stdin-file-path", "$FILENAME" }
    end
    -- only when biome.json{,c} don't exist
    return {
      "format",
      "--stdin-file-path",
      "$FILENAME",
      "--indent-style",
      vim.bo[ctx.buf].expandtab and "space" or "tab",
      "--indent-width",
      ctx.shiftwidth,
    }
  end,
  cwd = util.root_file({
    "biome.json",
    "biome.jsonc",
  }),
}
