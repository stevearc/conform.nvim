---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/jonschlinkert/markdown-toc",
    description = "API and CLI for generating a markdown TOC (table of contents) for a README or any markdown files.",
  },
  command = "markdown-toc",
  stdin = false,
  args = function(self, ctx)
    -- use the indentation set in the current buffer, effectively allowing us to
    -- use values from .editorconfig
    local indent = vim.bo[ctx.buf].expandtab and (" "):rep(vim.bo[ctx.buf].tabstop) or "\t"
    return { "--indent=" .. indent, "-i", "$FILENAME" }
  end,
}
