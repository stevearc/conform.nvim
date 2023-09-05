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

-- Format asynchronously on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ async = true, lsp_fallback = true, bufnr = args.buf }, function(err)
      if not err then
        vim.api.nvim_buf_call(args.buf, function()
          vim.cmd.update()
        end)
      end
    end)
  end,
})
