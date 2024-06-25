---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/nvuillam/npm-groovy-lint",
    description = "Lint, format and auto-fix your Groovy / Jenkinsfile / Gradle files using command line.",
  },
  command = "npm-groovy-lint",
  args = { "--fix", "$FILENAME" },
  -- https://github.com/nvuillam/npm-groovy-lint/blob/14e2649ff7ca642dba3e901c17252b178bea8b1b/lib/groovy-lint.js#L48
  exit_codes = { 0, 1 }, -- 1 = expected error
  stdin = false,
}
