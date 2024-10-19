local test_util = require("tests.test_util")
local util = require("conform.util")

local TMP_DIR = "./tmp/util/"

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

  describe("cwd", function()
    local dummy_self = {
      command = "echo",
      args = { "hello" },
    }

    before_each(function()
      vim.fn.mkdir(TMP_DIR, "p")
    end)

    after_each(function()
      vim.fn.delete(TMP_DIR, "rf")
    end)

    it("handles marker function", function()
      vim.fn.writefile({ "" }, vim.fs.joinpath(TMP_DIR, "marker.txt"))

      local cwd = util.root_file(function(name)
        return name == "marker.txt"
      end)(dummy_self, {
        dirname = TMP_DIR,
        filename = "some.js",
        bufnr = 1,
        buf = 1,
        shiftwidth = 2,
      })

      assert.equal(vim.fn.fnamemodify(TMP_DIR, ":p:h"), cwd)
    end)

    describe("single file", function()
      it("not found", function()
        local cwd = util.root_file("marker.txt")(dummy_self, {
          dirname = TMP_DIR,
          filename = "some.js",
          bufnr = 1,
          buf = 1,
          shiftwidth = 2,
        })

        assert.equal(nil, cwd)
      end)

      it("found", function()
        vim.fn.writefile({ "" }, vim.fs.joinpath(TMP_DIR, "marker.txt"))

        local cwd = util.root_file("marker.txt")(dummy_self, {
          dirname = TMP_DIR,
          filename = "some.js",
          bufnr = 1,
          buf = 1,
          shiftwidth = 2,
        })

        assert.equal(vim.fn.fnamemodify(TMP_DIR, ":p:h"), cwd)
      end)
    end)

    describe("many markers", function()
      it("not found", function()
        local cwd = util.root_file({ "marker.txt", ".markerrc" })(dummy_self, {
          dirname = TMP_DIR,
          filename = "some.js",
          bufnr = 1,
          buf = 1,
          shiftwidth = 2,
        })

        assert.equal(nil, cwd)
      end)

      it("found", function()
        vim.fn.writefile({ "" }, vim.fs.joinpath(TMP_DIR, "marker.txt"))

        local cwd = util.root_file({ "marker.txt", ".markerrc" })(dummy_self, {
          dirname = TMP_DIR,
          filename = "some.js",
          bufnr = 1,
          buf = 1,
          shiftwidth = 2,
        })

        assert.equal(vim.fn.fnamemodify(TMP_DIR, ":p:h"), cwd)
      end)
    end)
  end)
end)
