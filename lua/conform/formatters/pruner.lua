---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/pruner-formatter/pruner",
    description = "A language-agnostic, treesitter powered formatter.",
  },
  command = "pruner",
  args = function(_, ctx)
    local args = { "format" }

    local textwidth = vim.api.nvim_get_option_value("textwidth", {
      buf = ctx.buf,
    })
    if textwidth and textwidth > 0 then
      table.insert(args, "--print-width=" .. textwidth)
    end

    local filetype = vim.api.nvim_get_option_value("filetype", {
      buf = ctx.buf,
    })
    table.insert(args, "--lang=" .. filetype)

    return args
  end,
  stdin = true,
}
