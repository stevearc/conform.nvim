local extensions = {
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
  -- Requires `--unstable-component` flag or
  -- `"unstable": ["fmt-component]` config option.
  astro = "astro",
  svelte = "svelte",
  vue = "vue",
}
---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://deno.land/manual/tools/formatter",
    description = "Use [Deno](https://deno.land/) to format TypeScript, JavaScript/JSON and markdown.",
  },
  command = "deno",
  args = function(self, ctx)
    return {
      "fmt",
      "-",
      "--ext",
      extensions[vim.bo[ctx.buf].filetype],
    }
  end,
}
