local util = require("conform.util")
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/biomejs/biome",
    description = "A toolchain for web projects, aimed to provide functionalities to maintain them.",
  },
  command = util.from_node_modules("biome"),
  stdin = true,
  args = function(_, ctx)
    return {
      "format",
      "--stdin-file-path",
      "$FILENAME",
      "--indent-style",
      vim.bo[ctx.buf].expandtab and "space" or "tab",
      "--indent-width",
      ctx.shiftwidth > 0 and ctx.shiftwidth or 2,
    }
  end,
  cwd = util.root_file({
    "biome.json",
    "biome.jsonc",
  }),
}
