local fs = require("conform.fs")
local util = require("conform.util")

--- Helper function to parse options to into a parser if available
---@param self conform.JobFormatterConfig
---@param ctx conform.Context|conform.RangeContext
---@return string[]|nil args the arguments for setting a `prettier` parser if they exist in the options, nil otherwise
local function eval_parser(self, ctx)
  local ft = vim.bo[ctx.buf].filetype
  local ext = vim.fn.fnamemodify(ctx.filename, ":e")
  local options = self.options
  local parser = options
    and (
      (options.ft_parsers and options.ft_parsers[ft])
      or (options.ext_parsers and options.ext_parsers[ext])
    )
  if parser then
    return { "--parser", parser }
  end
end

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/prettier/prettier",
    description = [[Prettier is an opinionated code formatter. It enforces a consistent style by parsing your code and re-printing it with its own rules that take the maximum line length into account, wrapping code when necessary.]],
  },
  options = {
    -- Use a specific prettier parser for a filetype
    -- Otherwise, prettier will try to infer the parser from the file name
    ft_parsers = {
      --     javascript = "babel",
      --     javascriptreact = "babel",
      --     typescript = "typescript",
      --     typescriptreact = "typescript",
      --     vue = "vue",
      --     css = "css",
      --     scss = "scss",
      --     less = "less",
      --     html = "html",
      --     json = "json",
      --     jsonc = "json",
      --     yaml = "yaml",
      --     markdown = "markdown",
      --     ["markdown.mdx"] = "mdx",
      --     graphql = "graphql",
      --     handlebars = "glimmer",
    },
    -- Use a specific prettier parser for a file extension
    ext_parsers = {
      -- qmd = "markdown",
    },
  },
  command = util.from_node_modules(fs.is_windows and "prettier.cmd" or "prettier"),
  args = function(self, ctx)
    return eval_parser(self, ctx) or { "--stdin-filepath", "$FILENAME" }
  end,
  range_args = function(self, ctx)
    local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
    local args = eval_parser(self, ctx) or { "--stdin-filepath", "$FILENAME" }
    return vim.list_extend(args, { "--range-start=" .. start_offset, "--range-end=" .. end_offset })
  end,
  cwd = util.root_file({
    -- https://prettier.io/docs/en/configuration.html
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.json5",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.toml",
    "prettier.config.js",
    "prettier.config.cjs",
    "package.json",
  }),
}
