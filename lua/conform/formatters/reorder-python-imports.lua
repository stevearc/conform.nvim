--@type conform.FileFormatterConfig-
return {
  meta = {
    url = "https://github.com/asottile/reorder-python-imports",
    description = "Rewrites source to reorder python imports",
  },
  command = "reorder-python-imports",
  args = { "--exit-zero-even-if-changed", "-" },
  stdin = true,
}
