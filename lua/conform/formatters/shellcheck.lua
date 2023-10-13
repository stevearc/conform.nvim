---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/koalaman/shellcheck",
    description = "A static analysis tool for shell scripts.",
  },
  command = "shellcheck",
  args = "'$FILENAME' --format=diff | patch -p1 '$FILENAME'",
  stdin = false,
}
