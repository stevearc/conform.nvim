---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/crate-ci/typos",
    description = "Source code spell checker",
  },
  command = "typos",
  stdin = true,
  args = { "--write-changes", "-" },
  exit_codes = { 0, 2 },
}
