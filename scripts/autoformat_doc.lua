-- Format synchronously on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    -- Disable autoformat on certain filetypes
    local ignore_filetypes = { "sql", "java" }
    if vim.tbl_contains(ignore_filetypes, vim.bo[args.buf].filetype) then
      return
    end
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then
      return
    end
    -- Disable autoformat for files in a certain path
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname:match("/node_modules/") then
      return
    end
    require("conform").format({ timeout_ms = 500, lsp_fallback = true, bufnr = args.buf })
  end,
})

-- To eliminate the boilerplate, you can pass a function to format_on_save
-- and it will be called during the BufWritePre callback.
require("conform").setup({
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
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
