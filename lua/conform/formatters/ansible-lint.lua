---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/ansible/ansible-lint",
    description = "ansible-lint with --fix",
  },
  command = "ansible-lint",
  -- args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
  args = { "-f", "codeclimate", "-q", "--fix=all", "$FILENAME" },
  options = {
    ignore_errors = true,
    timeout_ms = 10000
  },
}
