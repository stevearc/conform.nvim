---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/ansible/ansible-lint",
    description = "ansible-lint with --fix.",
  },
  command = "ansible-lint",
  args = { "-f", "codeclimate", "-q", "--fix=all", "$FILENAME" },
  stdin = false,
  exit_codes = { 0, 2 },
}
