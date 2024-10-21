local log = require("conform.log")

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
    local extension = extensions[vim.bo[ctx.buf].filetype]

    -- TODO: How do I check if the user has passed in `--unstable-component` with e.g. `append_args` in their config?
    print("self: " .. vim.inspect(self))
    print("ctx: " .. vim.inspect(ctx))
    if true then
      log.warn(
        "You are trying to format an unstable file type (."
          .. extension
          .. ") without the corresponding `--unstable-component` flag. Add the flag to `append_args` to format your code. See the Deno documentation for more information: https://docs.deno.com/runtime/reference/cli/formatter/#formatting-options-unstable-component"
      )
    end

    return {
      "fmt",
      "-",
      "--ext",
      extension,
    }
  end,
}
