# Recipes

<!-- TOC -->

- [Format command](#format-command)
- [Autoformat with extra features](#autoformat-with-extra-features)
- [Command to toggle format-on-save](#command-to-toggle-format-on-save)
- [Lazy loading with lazy.nvim](#lazy-loading-with-lazynvim)
- [Leave visual mode after range format](#leave-visual-mode-after-range-format)
- [Run the first available formatter followed by more formatters](#run-the-first-available-formatter-followed-by-more-formatters)

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
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })
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
    return { timeout_ms = 500, lsp_format = "fallback" }
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
    return { lsp_format = "fallback" }
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
    return { timeout_ms = 500, lsp_format = "fallback" }
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

## Lazy loading with lazy.nvim

Here is the recommended config for lazy-loading using lazy.nvim

```lua
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      "<leader>f",
      function()
        require("conform").format({ async = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Set up format-on-save
    format_on_save = { timeout_ms = 500 },
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
```

## Leave visual mode after range format

If you call `conform.format` when in visual mode, conform will perform a range format on the selected region. If you want it to leave visual mode afterwards (similar to the default `gw` or `gq` behavior), use this mapping:

```lua
vim.keymap.set("", "<leader>f", function()
  require("conform").format({ async = true }, function(err)
    if not err then
      local mode = vim.api.nvim_get_mode().mode
      if vim.startswith(string.lower(mode), "v") then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
      end
    end
  end)
end, { desc = "Format code" })
```

## Run the first available formatter followed by more formatters

With the refactor in [#491](https://github.com/stevearc/conform.nvim/pull/491) it is now easy to
just run the first available formatter in a list, but more difficult to do that _and then_ run
another formatter. For example, "format first with either `prettierd` or `prettier`, _then_ use the
`injected` formatter". Here is how you can easily do that:

```lua
---@param bufnr integer
---@param ... string
---@return string
local function first(bufnr, ...)
  local conform = require("conform")
  for i = 1, select("#", ...) do
    local formatter = select(i, ...)
    if conform.get_formatter_info(formatter, bufnr).available then
      return formatter
    end
  end
  return select(1, ...)
end

require("conform").setup({
  formatters_by_ft = {
    markdown = function(bufnr)
      return { first(bufnr, "prettierd", "prettier"), "injected" }
    end,
  },
})
```
