return {
  meta = {
    url = "https://github.com/casey/just",
    description = "Format Justfile.",
  },
  command = "just",
  args = { "--fmt", "--unstable", "-f", "$FILENAME" },
  stdin = false,
}
