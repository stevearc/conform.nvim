local test_util = require("tests.test_util")
local util = require("conform.util")

describe("util", function()
  local shell = vim.o.shell
  local shellcmdflag = vim.o.shellcmdflag
  local shellxescape = vim.o.shellxescape
  local shellxquote = vim.o.shellxquote
  after_each(function()
    test_util.reset_editor()
    vim.o.shell = shell
    vim.o.shellcmdflag = shellcmdflag
    vim.o.shellxescape = shellxescape
    vim.o.shellxquote = shellxquote
  end)

  describe("shell_build_argv", function()
    it("builds simple command", function()
      vim.o.shell = "/bin/bash"
      vim.o.shellcmdflag = "-c"
      vim.o.shellxescape = ""
      vim.o.shellxquote = ""
      local argv = util.shell_build_argv("echo hello")
      assert.are_same({ "/bin/bash", "-c", "echo hello" }, argv)
    end)

    it("handles shell arguments", function()
      vim.o.shell = "/bin/bash -f"
      vim.o.shellcmdflag = "-c"
      vim.o.shellxescape = ""
      vim.o.shellxquote = ""
      local argv = util.shell_build_argv("echo hello")
      assert.are_same({ "/bin/bash", "-f", "-c", "echo hello" }, argv)
    end)

    it("handles shell with spaces", function()
      vim.o.shell = '"c:\\program files\\unix\\sh.exe"'
      vim.o.shellcmdflag = "-c"
      vim.o.shellxescape = ""
      vim.o.shellxquote = ""
      local argv = util.shell_build_argv("echo hello")
      assert.are_same({ "c:\\program files\\unix\\sh.exe", "-c", "echo hello" }, argv)
    end)

    it("handles shell with spaces and args", function()
      vim.o.shell = '"c:\\program files\\unix\\sh.exe" -f'
      vim.o.shellcmdflag = "-c"
      vim.o.shellxescape = ""
      vim.o.shellxquote = ""
      local argv = util.shell_build_argv("echo hello")
      assert.are_same({ "c:\\program files\\unix\\sh.exe", "-f", "-c", "echo hello" }, argv)
    end)

    it("applies shellxquote", function()
      vim.o.shell = "/bin/bash"
      vim.o.shellcmdflag = "-c"
      vim.o.shellxescape = ""
      vim.o.shellxquote = "'"
      local argv = util.shell_build_argv("echo hello")
      assert.are_same({ "/bin/bash", "-c", "'echo hello'" }, argv)
    end)

    it("uses shellxescape", function()
      vim.o.shell = "/bin/bash"
      vim.o.shellcmdflag = "-c"
      vim.o.shellxescape = "el"
      vim.o.shellxquote = "("
      local argv = util.shell_build_argv("echo hello")
      assert.are_same({ "/bin/bash", "-c", "(^echo h^e^l^lo)" }, argv)
    end)
  end)
end)
