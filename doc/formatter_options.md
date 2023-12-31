# Formatter Options

<!-- TOC -->

- [injected](#injected)
- [prettier](#prettier)

<!-- /TOC -->

All formatters can be customized by directly changing the command, args, or other values (see [customizing formatters](../README.md#customizing-formatters)). Some formatters have a bit more advanced logic built in to those functions and expose additional configuration options. You can pass these values in like so:

```lua
-- Customize the "injected" formatter
require("conform").formatters.injected = {
  -- Set the options field
  options = {
    -- Set individual option values
    ignore_errors = true,
    lang_to_formatters = {
      json = { "jq" },
    },
  },
}
```

<!-- OPTIONS -->

## injected

```lua
options = {
  -- Set to true to ignore errors
  ignore_errors = false,
  -- Map of treesitter language to file extension
  -- A temporary file name with this extension will be generated during formatting
  -- because some formatters care about the filename.
  lang_to_ext = {
    bash = "sh",
    c_sharp = "cs",
    elixir = "exs",
    javascript = "js",
    julia = "jl",
    latex = "tex",
    markdown = "md",
    python = "py",
    ruby = "rb",
    rust = "rs",
    teal = "tl",
    typescript = "ts",
  },
  -- Map of treesitter language to formatters to use
  -- (defaults to the value from formatters_by_ft)
  lang_to_formatters = {},
}
```

## prettier

```lua
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
}
```

<!-- /OPTIONS -->
