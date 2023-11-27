---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/crate-ci/typos",
    description = "Source code spell checker",
  },
  command = "typos",
  -- cannot use stdin, as otherwise `typos` has no information on the filename,
  -- making excluded-file-configs ineffective
  stdin = false,
  args = {
    "--write-changes",
    "--force-exclude", -- so excluded files in the config take effect
    "$FILENAME",
  },
  exit_codes = { 0, 2 },
}
