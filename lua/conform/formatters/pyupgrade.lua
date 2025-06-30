--- NOTE: When adding pyupgrade to your config, you might want to add specific version flag
--- For instance use:
---   prepend_args = { "--py313-plus" }

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/asottile/pyupgrade",
    description = "A tool to automatically upgrade syntax for newer versions of Python.",
  },
  command = "pyupgrade",
  args = { "--exit-zero-even-if-changed", "$FILENAME" },
  stdin = false,
}
