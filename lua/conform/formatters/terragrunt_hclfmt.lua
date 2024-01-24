---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://terragrunt.gruntwork.io/docs/reference/cli-options/#hclfmt",
    description = "Format hcl files into a canonical format.",
  },
  command = "terragrunt",
  args = { "hclfmt", "--terragrunt-hclfmt-file", "$FILENAME" },
  stdin = false,
  condition = function(self, ctx)
    return vim.fs.basename(ctx.filename) ~= "terragrunt.hcl"
  end,
}
