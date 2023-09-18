---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://www.gnu.org/software/coreutils/manual/html_node/cat-invocation.html#cat-invocation",
    description = "Squeeze repeated blank lines into a single blank line via `cat -s`.",
  },
  command = "cat",
  args = { "-s" },
  stdin = true,
}
