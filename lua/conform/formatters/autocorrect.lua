---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/huacnlee/autocorrect",
    description = "A linter and formatter to help you to improve copywriting, correct spaces, words, and punctuations between CJK.",
  },
  command = "autocorrect",
  args = { "--stdin" },
  stdin = true,
}
