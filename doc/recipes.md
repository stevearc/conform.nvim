# Recipes

<!-- TOC -->

- [Format command](#format-command)
- [Customizing formatters](#customizing-formatters)
- [Autoformat with extra features](#autoformat-with-extra-features)
- [Command to toggle format-on-save](#command-to-toggle-format-on-save)

<!-- /TOC -->

## Format command

Define a command to run async formatting

```lua
vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })
```

## Customizing formatters

If you want to customize how a formatter runs (for example, to pass in environment variables or
change the command arguments), you can either edit the formatter directly or create one yourself.

```lua
-- Directly change the values on the built-in configuration
require("conform.formatters.yamlfix").env = {
  YAMLFIX_SEQUENCE_STYLE = "block_style",
}

-- Or create your own formatter that overrides certain values
require("conform").formatters.yamlfix = vim.tbl_deep_extend("force", require("conform.formatters.yamlfix"), {
  env = {
    YAMLFIX_SEQUENCE_STYLE = "block_style",
  },
})

-- Here is an example that modifies the command arguments for prettier to add
-- a custom config file, if it is present
require("conform.formatters.prettier").args = function(ctx)
  local args = { "--stdin-filepath", "$FILENAME" }
  local found = vim.fs.find(".custom-config.json", { upward = true, path = ctx.dirname })[1]
  if found then
    vim.list_extend(args, { "--config", found })
  end
  return args
end
```

## Autoformat with extra features

If you want more complex logic than the basic `format_on_save` option allows, you can use a function instead.

<!-- AUTOFORMAT -->

```lua
-- if format_on_save is a function, it will be called during BufWritePre
require("conform").setup({
  format_on_save = function(bufnr)
    -- Disable autoformat on certain filetypes
    local ignore_filetypes = { "sql", "java" }
    if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
      return
    end
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    -- Disable autoformat for files in a certain path
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname:match("/node_modules/") then
      return
    end
    -- ...additional logic...
    return { timeout_ms = 500, lsp_fallback = true }
  end,
})

-- There is a similar affordance for format_after_save, which uses BufWritePost.
-- This is good for formatters that are too slow to run synchronously.
require("conform").setup({
  format_after_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    -- ...additional logic...
    return { lsp_fallback = true }
  end,
})
```

<!-- /AUTOFORMAT -->

## Command to toggle format-on-save

Create user commands to quickly enable/disable autoformatting

```lua
require("conform").setup({
  format_on_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
})

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})
```
