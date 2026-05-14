local util = require("conform.util")

-- Map Neovim filetypes to Topiary language names
local ft_to_language = {
  bash = "bash",
  sh = "bash",
  css = "css",
  json = "json",
  nickel = "nickel",
  ocaml = "ocaml",
  rust = "rust",
  toml = "toml",
  query = "tree_sitter_query",
  wit = "wit",
  zsh = "zsh",
}

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://topiary.tweag.io",
    description = "A universal code formatter based on tree-sitter, supporting multiple languages with a consistent formatting style.",
  },
  command = "topiary",
  ---@param self conform.JobFormatterConfig
  ---@param ctx conform.Context
  condition = function(self, ctx)
    local ft = vim.bo[ctx.buf].filetype
    local language = self.options.language or ft_to_language[ft]
    return language ~= nil
  end,
  ---@param self conform.JobFormatterConfig
  ---@param ctx conform.Context
  args = function(self, ctx)
    local ft = vim.bo[ctx.buf].filetype
    local language = self.options.language or ft_to_language[ft]
    if not language then
      return {}
    end

    return {
      "format",
      "--language",
      language,
    }
  end,
  options = {
    -- Override the detected language for a specific filetype
    -- Example: { language = "bash" }
    language = nil,
  },
  stdin = true,
  cwd = util.root_file({
    ".topiary.toml",
    "topiary.toml",
  }),
}
