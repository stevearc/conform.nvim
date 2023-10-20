---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/puppetlabs/puppet-lint",
    description = "Check that your Puppet manifests conform to the style guide.",
  },
  command = "puppet-lint",
  args = { "--fix", "$FILENAME" },
  stdin = false,
  exit_codes = { 0, 1 },
}
