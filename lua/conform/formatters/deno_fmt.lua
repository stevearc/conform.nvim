local conform = require("conform")
local log = require("conform.log")

-- Requires `--unstable-component` flag or
-- `"unstable": ["fmt-component]` config option.
-- https://docs.deno.com/runtime/reference/cli/formatter/#formatting-options-unstable-component
local unstable_extensions = {
  astro = "astro",
  svelte = "svelte",
  vue = "vue",
}
local extensions = vim.tbl_extend("keep", {
  css = "css",
  esmodule = "mjs",
  html = "html",
  javascript = "js",
  javascriptreact = "jsx",
  json = "json",
  jsonc = "jsonc",
  less = "less",
  markdown = "md",
  sass = "sass",
  scss = "scss",
  typescript = "ts",
  typescriptreact = "tsx",
  yaml = "yml",
}, unstable_extensions)

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://deno.land/manual/tools/formatter",
    description = "Use [Deno](https://deno.land/) to format TypeScript, JavaScript/JSON and markdown.",
  },
  command = "deno",
  args = function(self, ctx)
    local extension = extensions[vim.bo[ctx.buf].filetype]
    local formatter_args = {
      "fmt",
      "-",
      "--ext",
      extension,
    }

    if
      vim.tbl_get(unstable_extensions, extension)
      and not vim.list_contains(
        vim.tbl_get(conform.formatters, "deno_fmt", "append_args") or {},
        "--unstable-component"
      )
    then
      log.info(
        "Adding `--unstable-component` to enable formatting of ."
          .. extension
          .. " files. See the Deno documentation for more information: https://docs.deno.com/runtime/reference/cli/formatter/#formatting-options-unstable-component"
      )
      formatter_args = vim.list_extend(formatter_args, { "--unstable-component" })
    end

    return formatter_args
  end,
}
