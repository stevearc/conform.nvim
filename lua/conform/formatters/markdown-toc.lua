---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/jonschlinkert/markdown-toc",
    description = "API and CLI for generating a markdown TOC (table of contents) for a README or any markdown files.",
  },
  command = "markdown-toc",
  stdin = false,
  args = function(_, ctx)
    -- use the indentation set in the current buffer, effectively allowing us to
    -- use values from .editorconfig
    local indent = "\t"
    local bo = vim.bo[ctx.buf]
    if bo.expandtab then
      local indent_size = bo.shiftwidth
      if indent_size == 0 or not indent_size then
        indent_size = bo.tabstop or 4 -- default is 4
      end
      indent = (" "):rep(indent_size)
    end
    return { "--indent=" .. indent, "-i", "$FILENAME" }
  end,
}
