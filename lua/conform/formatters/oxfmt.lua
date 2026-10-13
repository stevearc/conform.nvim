local util = require("conform.util")

local config_file_names = {
  -- https://oxc.rs/docs/guide/usage/formatter/config.html#create-a-config-file
  ".oxfmtrc.json",
  ".oxfmtrc.jsonc",
  "oxfmt.config.ts",
  -- https://viteplus.dev/guide/fmt#configuration
  "vite.config.ts",
  "vite.config.js",
}

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/oxc-project/oxc",
    description = "A Prettier-compatible code formatter.",
  },
  command = function(self, ctx)
    local command = util.find_executable(
      { "node_modules/.bin/oxfmt", "node_modules/.bin/vp" },
      "oxfmt"
    )(self, ctx)
    if vim.fn.executable(command) == 0 and vim.fn.executable("vp") == 1 then
      return "vp"
    end
    return command
  end,
  args = function(self, ctx)
    local command = self.command
    if type(command) == "function" then
      command = command(self, ctx)
    end
    if vim.fs.basename(command) == "vp" then
      return { "fmt", "--stdin-filepath", "$FILENAME" }
    end
    return { "--stdin-filepath", "$FILENAME" }
  end,
  stdin = true,
  cwd = require("conform.util").root_file(config_file_names),
}
