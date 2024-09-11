# Debugging

When you are experiencing problems with a formatter, this doc is intended to give you the background
information and tools you need to figure out what is going wrong. It should help you answer
questions like "why isn't my formatter working?" and "why is my formatter using the wrong format?"

<!-- TOC -->

- [Background](#background)
- [Tools](#tools)
- [Testing the formatter](#testing-the-formatter)
- [Testing vim.system](#testing-vimsystem)

<!-- /TOC -->

## Background

How does conform work?

Under the hood, conform is just running a shell command, capturing the output, and replacing the
buffer contents with that output. There are a few fancy things happening with [minimal format
diffs](advanced_topics.md#minimal-format-diffs), but in practice there are almost never problems
with that system so you can mostly ignore it.

Conform runs the formatters using `:help vim.system()`, and does one of two things. Some formatters
support formatting _from_ stdin and _to_ stdout. For these, we pipe the buffer text to the process
via stdin, and read the stdout back as the new buffer contents. For formatters that don't support
stdin/out, we create a temporary file in the same directory, write the buffer to it, run the
formatter, and read back the modified tempfile as the new buffer contents.

## Tools

Conform has two very useful tools for debugging misbehaving formatters: logging and `:ConformInfo`.
Try running `:ConformInfo` now; you should see something like the window below:

<img width="1243" alt="Screenshot 2024-08-07 at 10 03 17 PM" src="https://github.com/user-attachments/assets/2dbbc2b7-05c1-4c9f-bb8c-345d039b624c">

This contains a snippet of the log file, the location of the log file in case you need to see more
logs (you can use `gf` to jump to it), available formatters for the current buffer, and a list of
all the configured formatters. Each formatter has a status, an error message if there is something
wrong, a list of filetypes it applies to, and the resolved path to the executable.

This should be enough to fix many issues. Double check to make sure your formatter is `ready` and
that it is configured to run on the filetype(s) you expect. Also double check the path to the
executable. If all of those look good, then it's time to make more use of the logs.

The first thing you will want to do is increase the verbosity of the logs. Do this by setting the
`log_level` option:

```lua
require("conform").setup({
  log_level = vim.log.levels.DEBUG,
})
```

It is recommended to start with `DEBUG` level. You can also use `TRACE`, which will log the entire
file input and output to the formatter. This can be helpful in some situations, but takes up a lot
of visual space and so is not recommended until you need that information specifically.

## Testing the formatter

Once you set the log level, try the format operations again, then open the log file (remember, you
can find it from `:ConformInfo`). You're looking for the lines that tell you what command is being
run. It should look like this:

```
21:50:31[DEBUG] Run command: { "black", "--stdin-filename", "/Users/stevearc/dotfiles/vimplugins/conform.nvim/scripts/generate.py", "--quiet", "-" }
21:50:31[DEBUG] Run default CWD: /Users/stevearc/dotfiles/vimplugins/conform.nvim
```

This is logging the lua table that is passed to `vim.system()`. The first thing to do is to take this
command and run it directly in your shell and see what happens. For formatters using stdin/out, it
will look like this:

```
cat path/to/file.py | black --stdin-filename path/to/file.py --quiet -
```

Note that this will print the entire formatted file to stdout. It will be much easier for you if you
can come up with a small test file just a couple lines long that reproduces this issue. MAKE SURE
that you `cd` into the CWD directory from the log lines, as that is the directory that conform will
run the command from. If your formatter doesn't use stdin/out, do the same thing but omit the `cat`.
The command in the log line will contain a path to a temporary file. Just replace that with the path
to the real file:

```
black --quiet path/to/file.py
```

**Q:** What is the point of all of this? \
**A:** We're trying to isolate where the problem is coming from: the formatter, the environment
configuring the formatter, Neovim, or conform. By confirming that the format command works in the
shell, we can eliminate some of those possibilities. If the format command _doesn't_ work in the
shell, you will need to iterate on that until you can find one that works. Please DO NOT file an
issue on this repo until you have a functioning format command in your shell.

## Testing vim.system

What to do if the formatting command works on the command line? Well, now we need to determine if the issue is with conform or if it's with the underlying Neovim utilities. To isolate this, we're going to attempt to run the command using raw Neovim APIs the same way that conform would. If this succeeds, we can be confident that something is wrong with conform. If this fails, then it is likely that there is an upstream issue with `vim.system`, or possibly that conform needs to call `vim.system` in a different way.

Copy this script into a lua file, edit the bottom to match your use case, and run it with `:source`.

```lua
-- Copy these helper functions directly
local function run_formatter(cmd, cwd, buffer_text)
  local proc = vim.system(cmd, {
    cwd = cwd,
    stdin = buffer_text,
    text = true,
  })
  local ret = proc:wait()
  if ret.code == 0 then
    print("Success\n--------")
  else
    print("Failure\n--------")
  end
  print(ret.stdout)
  print(ret.stderr)
end

local function read_file(path)
  local file = assert(io.open(path, "r"))
  local content = file:read("*a")
  file:close()
  return content
end

-- Edit these lines to match the values you see in your conform log file
-- To test a stdin formatter
run_formatter({ "formatter_command", "arg1", "arg2" }, "/path/to/cwd", read_file("/path/to/file.txt"))
-- To test a non-stdin formatter
run_formatter({ "formatter_command", "arg1", "arg2" }, "/path/to/cwd")
```
