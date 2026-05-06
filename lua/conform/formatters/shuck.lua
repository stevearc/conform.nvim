---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/ewhauser/shuck",
    description = "A lightning fast shell linter and formatter.",
  },
  command = "shuck",
  args = function(_, ctx)
    local args = { "format", "--stdin-filename", "$FILENAME" }
    local has_config = vim.fs.find(".shuck.toml", { path = ctx.dirname, upward = true })[1] ~= nil
    -- If there is a shuck.toml, don't pass any args because shuck will apply settings from there
    -- when no command line args are passed.
    if not has_config then
      if vim.bo[ctx.buf].expandtab then
        vim.list_extend(args, { "--indent-style", "space" })
      else
        vim.list_extend(args, { "--indent-style", "tab" })
      end
      vim.list_extend(args, { "--indent-width", ctx.shiftwidth })
    end
    vim.list_extend(args, { "-" })
    return args
  end,
  env = {
    SHUCK_EXPERIMENTAL = "1",
  },
}
