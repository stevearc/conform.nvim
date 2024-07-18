---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/mvdan/sh",
    description = "A shell parser, formatter, and interpreter with `bash` support.",
  },
  command = "shfmt",
  args = function(_, ctx)
    local args = { "-filename", "$FILENAME" }
    local has_editorconfig = vim.fs.find(".editorconfig", { path = ctx.dirname, upward = true })[1]
      ~= nil
    -- If there is an editorconfig, don't pass any args because shfmt will apply settings from there
    -- when no command line args are passed.
    if not has_editorconfig and vim.bo[ctx.buf].expandtab then
      vim.list_extend(args, { "-i", ctx.shiftwidth })
    end
    return args
  end,
}
