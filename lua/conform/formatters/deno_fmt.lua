local log = require("conform.log")

-- Requires `--unstable-component` flag
-- https://docs.deno.com/runtime/reference/cli/fmt/#supported-file-types
local unstable_component = {
  astro = "astro",
  svelte = "svelte",
  vue = "vue",
}
-- Requires `--unstable-sql` flag
-- https://docs.deno.com/runtime/reference/cli/fmt/#supported-file-types
local unstable_sql = {
  sql = "sql",
}
local extensions = vim.tbl_extend("keep", {
  -- js
  javascript = "js",
  javascriptreact = "jsx",
  typescript = "ts",
  typescriptreact = "tsx",
  -- css
  css = "css",
  scss = "scss",
  less = "less",
  -- markup
  html = "html",
  -- config
  json = "json",
  jsonc = "jsonc",
  yaml = "yml",
  -- other
  markdown = "md",
}, unstable_component, unstable_sql)

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://docs.deno.com/runtime/reference/cli/fmt/",
    description = "Use [Deno](https://deno.land/) to format TypeScript, JavaScript, JSON, Markdown and more.",
  },
  command = "deno",
  cond = function(self, ctx)
    return extensions[vim.bo[ctx.buf].filetype] ~= nil
  end,
  args = function(self, ctx)
    local formatter_args = { "fmt", "-" }

    local extension = extensions[vim.bo[ctx.buf].filetype]

    if extension then
      formatter_args = vim.list_extend(formatter_args, { "--ext", extension })
    end

    if unstable_component[extension] then
      log.info(
        "Adding `--unstable-component` to enable formatting of .%s files. See the Deno documentation for more information: https://docs.deno.com/runtime/reference/cli/fmt/#supported-file-types",
        extension
      )
      formatter_args = vim.list_extend(formatter_args, { "--unstable-component" })
    end

    if unstable_sql[extension] then
      log.info(
        "Adding `--unstable-sql` to enable formatting of .%s files. See the Deno documentation for more information: https://docs.deno.com/runtime/reference/cli/fmt/#supported-file-types",
        extension
      )
      formatter_args = vim.list_extend(formatter_args, { "--unstable-sql" })
    end

    return formatter_args
  end,
}
