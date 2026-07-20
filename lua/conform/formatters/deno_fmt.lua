local log = require("conform.log")

-- Some formats require --unstable-x flags to be passed to the formatter
-- https://docs.deno.com/runtime/reference/cli/fmt/#supported-file-types
--
-- Requires `--unstable-component` flag
local unstable_component = {
  astro = "astro",
  svelte = "svelte",
  vue = "vue",
}
-- Requires `--unstable-sql` flag
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
  less = "less",
  scss = "scss",
  -- markup
  html = "html",
  svg = "svg",
  xml = "xml",
  -- data / config
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
    description = "Use [Deno](https://deno.com/) to format TypeScript, JavaScript, JSON, Markdown and more.",
  },
  command = "deno",
  cond = function(_, ctx)
    return extensions[vim.bo[ctx.buf].filetype] ~= nil
  end,
  args = function(_, ctx)
    local extension = extensions[vim.bo[ctx.buf].filetype]

    local formatter_args = {
      "fmt",
      "-",
      "--ext",
      extension,
    }

    if unstable_component[extension] then
      log.info(
        "Adding `--unstable-component` to enable formatting of .%s files: https://docs.deno.com/runtime/reference/cli/fmt/#supported-file-types",
        extension
      )
      formatter_args = vim.list_extend(formatter_args, { "--unstable-component" })
    end

    if unstable_sql[extension] then
      log.info(
        "Adding `--unstable-sql` to enable formatting of .%s files: https://docs.deno.com/runtime/reference/cli/fmt/#supported-file-types",
        extension
      )
      formatter_args = vim.list_extend(formatter_args, { "--unstable-sql" })
    end

    return formatter_args
  end,
}
