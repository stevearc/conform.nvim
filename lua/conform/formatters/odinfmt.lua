---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/DanielGavin/ols",
    description = "Auto-formatter for the Odin programming language.",
  },
  command = "odinfmt",
  args = {
    -- Odinfmt hunts for the first "odinfmt.json" file it finds from the
    -- current directory and back up the file system. All formatting directives
    -- are in that file.
    --
    -- Odinfmt writes to stdout by default, but must be directed to read from
    -- stdin.
    "-stdin",
  },
  stdin = true,
}
