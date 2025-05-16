--@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/mondeja/hledger-fmt",
    description = "An opinionated hledger's journal files formatter.",
  },
  command = "hledger-fmt",
  args = { "--no-diff", "-" },
  stdin = true,
}
