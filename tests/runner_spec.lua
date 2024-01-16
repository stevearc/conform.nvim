require("plenary.async").tests.add_to_env()
local conform = require("conform")
local runner = require("conform.runner")
local test_util = require("tests.test_util")
local util = require("conform.util")

describe("runner", function()
  local OUTPUT_FILE
  local CLEANUP_FILES = {}

  ---@param lines string[]
  local function set_formatter_output(lines)
    local fd, output_file = vim.loop.fs_mkstemp(".testenv/outputXXXXXXXXX")
    assert(type(fd) == "number" and output_file, fd)
    local content = table.concat(lines, "\n")
    vim.loop.fs_write(fd, content)
    -- Make sure we add the final newline
    vim.loop.fs_write(fd, "\n")
    vim.loop.fs_fsync(fd)
    vim.loop.fs_close(fd)
    OUTPUT_FILE = output_file
    table.insert(CLEANUP_FILES, output_file)
  end

  after_each(function()
    test_util.reset_editor()
    OUTPUT_FILE = nil
    for _, file in ipairs(CLEANUP_FILES) do
      if vim.loop.fs_stat(file) then
        vim.loop.fs_unlink(file)
      end
    end
    CLEANUP_FILES = {}
  end)

  it("resolves config function", function()
    conform.formatters.test = function()
      return {
        meta = { url = "", description = "" },
        command = "echo",
      }
    end
    local config = assert(conform.get_formatter_config("test"))
    assert.are.same({
      meta = { url = "", description = "" },
      command = "echo",
      stdin = true,
    }, config)
  end)

  describe("build_context", function()
    it("sets the filename and dirname", function()
      vim.cmd.edit({ args = { "README.md" } })
      local bufnr = vim.api.nvim_get_current_buf()
      conform.formatters.test = {
        meta = { url = "", description = "" },
        command = "echo",
      }
      local config = assert(conform.get_formatter_config("test"))
      local ctx = runner.build_context(0, config)
      local filename = vim.api.nvim_buf_get_name(bufnr)
      assert.are.same({
        buf = bufnr,
        filename = filename,
        dirname = vim.fs.dirname(filename),
      }, ctx)
    end)

    it("sets temp file when stdin = false", function()
      vim.cmd.edit({ args = { "README.md" } })
      local bufnr = vim.api.nvim_get_current_buf()
      conform.formatters.test = {
        meta = { url = "", description = "" },
        command = "echo",
        stdin = false,
      }
      local config = assert(conform.get_formatter_config("test"))
      local ctx = runner.build_context(0, config)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local dirname = vim.fs.dirname(bufname)
      assert.equal(bufnr, ctx.buf)
      assert.equal(dirname, ctx.dirname)
      assert.truthy(ctx.filename:match(dirname .. "/.conform.%d+.README.md$"))
    end)
  end)

  describe("build_cmd", function()
    it("replaces $FILENAME in args", function()
      vim.cmd.edit({ args = { "README.md" } })
      local bufnr = vim.api.nvim_get_current_buf()
      conform.formatters.test = {
        meta = { url = "", description = "" },
        command = "echo",
        args = { "$FILENAME" },
      }
      local config = assert(conform.get_formatter_config("test"))
      local ctx = runner.build_context(0, config)
      local cmd = runner.build_cmd("", ctx, config)
      assert.are.same({ "echo", vim.api.nvim_buf_get_name(bufnr) }, cmd)
    end)

    it("replaces $DIRNAME in args", function()
      vim.cmd.edit({ args = { "README.md" } })
      local bufnr = vim.api.nvim_get_current_buf()
      conform.formatters.test = {
        meta = { url = "", description = "" },
        command = "echo",
        args = { "$DIRNAME" },
      }
      local config = assert(conform.get_formatter_config("test"))
      local ctx = runner.build_context(0, config)
      local cmd = runner.build_cmd("", ctx, config)
      assert.are.same({ "echo", vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)) }, cmd)
    end)

    it("resolves arg function", function()
      vim.cmd.edit({ args = { "README.md" } })
      conform.formatters.test = {
        meta = { url = "", description = "" },
        command = "echo",
        args = function()
          return { "--stdin" }
        end,
      }
      local config = assert(conform.get_formatter_config("test"))
      local ctx = runner.build_context(0, config)
      local cmd = runner.build_cmd("", ctx, config)
      assert.are.same({ "echo", "--stdin" }, cmd)
    end)

    it("replaces $FILENAME in string args", function()
      vim.cmd.edit({ args = { "README.md" } })
      local bufnr = vim.api.nvim_get_current_buf()
      conform.formatters.test = {
        meta = { url = "", description = "" },
        command = "echo",
        args = "$FILENAME | patch",
      }
      local config = assert(conform.get_formatter_config("test"))
      local ctx = runner.build_context(0, config)
      local cmd = runner.build_cmd("", ctx, config)
      assert.equal("echo " .. vim.api.nvim_buf_get_name(bufnr) .. " | patch", cmd)
    end)

    it("replaces $DIRNAME in string args", function()
      vim.cmd.edit({ args = { "README.md" } })
      local bufnr = vim.api.nvim_get_current_buf()
      conform.formatters.test = {
        meta = { url = "", description = "" },
        command = "echo",
        args = "$DIRNAME | patch",
      }
      local config = assert(conform.get_formatter_config("test"))
      local ctx = runner.build_context(0, config)
      local cmd = runner.build_cmd("", ctx, config)
      assert.equal("echo " .. vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)) .. " | patch", cmd)
    end)

    it("resolves arg function with string results", function()
      vim.cmd.edit({ args = { "README.md" } })
      conform.formatters.test = {
        meta = { url = "", description = "" },
        command = "echo",
        args = function()
          return "| patch"
        end,
      }
      local config = assert(conform.get_formatter_config("test"))
      local ctx = runner.build_context(0, config)
      local cmd = runner.build_cmd("", ctx, config)
      assert.equal("echo | patch", cmd)
    end)
  end)

  describe("e2e", function()
    before_each(function()
      conform.formatters.test = {
        command = "tests/fake_formatter.sh",
        args = function()
          if OUTPUT_FILE then
            return { OUTPUT_FILE }
          end
          return {}
        end,
      }
    end)

    ---@param buf_content string
    ---@param expected string
    ---@param opts? table
    local function run_formatter(buf_content, expected, opts)
      local bufnr = vim.fn.bufadd("testfile")
      vim.fn.bufload(bufnr)
      vim.api.nvim_set_current_buf(bufnr)
      local lines = vim.split(buf_content, "\n", { plain = true })
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
      vim.bo[bufnr].modified = false
      local expected_lines = vim.split(expected, "\n", { plain = true })
      set_formatter_output(expected_lines)
      conform.format(vim.tbl_extend("keep", opts or {}, { formatters = { "test" }, quiet = true }))
      return expected_lines
    end

    ---@param buf_content string
    ---@param new_content string
    local function run_formatter_test(buf_content, new_content)
      local lines = run_formatter(buf_content, new_content)
      assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    end

    it("sets the correct output", function()
      run_formatter_test(
        [[
        if true {
        print("hello")
      }]],
        [[
      if true {
        print("hello")
      }]]
      )
      run_formatter_test(
        [[
      if true {
        print("hello")
      }]],
        [[
      if true {
        print("goodbye")
      }]]
      )
      run_formatter_test(
        [[
      if true {
        print("hello")
      }]],
        [[
      if true {
        print("hello world")
        print("hello world")
        print("hello world")
      }]]
      )
      run_formatter_test(
        [[
print("a")
print("b")
print("c")
      ]],
        [[
print("c")
print("b")
print("a")
      ]]
      )
      run_formatter_test("hello\ngoodbye", "hello\n\n\ngoodbye")
      run_formatter_test("hello", "hello\ngoodbye")
      run_formatter_test("hello\ngoodbye", "hello")
      run_formatter_test("", "hello")
      run_formatter_test("\nfoo", "\nhello\nfoo")
      run_formatter_test("hello", "hello\n")
      run_formatter_test("hello", "hello\n\n")
      run_formatter_test("hello\n", "hello")
      run_formatter_test("hello\n ", "hello")

      -- These should generate no changes to the buffer
      run_formatter_test("hello\n", "hello\n")
      assert.falsy(vim.bo.modified)
      run_formatter_test("hello", "hello")
      assert.falsy(vim.bo.modified)
    end)

    it("does not change output if formatter fails", function()
      conform.formatters.test.args = util.extend_args(conform.formatters.test.args, { "--fail" })
      run_formatter("hello", "goodbye")
      assert.are.same({ "hello" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    end)

    it("allows nonzero exit codes", function()
      conform.formatters.test.args = util.extend_args(conform.formatters.test.args, { "--fail" })
      conform.formatters.test.exit_codes = { 0, 1 }
      run_formatter_test("hello", "goodbye")
    end)

    it("does not format if it times out", function()
      conform.formatters.test.args = util.extend_args(conform.formatters.test.args, { "--timeout" })
      run_formatter("hello", "goodbye", { timeout_ms = 10 })
      assert.are.same({ "hello" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    end)

    it("can format async", function()
      run_formatter("hello", "goodbye", { async = true })
      assert.are.same({ "hello" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
      vim.wait(1000, function()
        return vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == "goodbye"
      end)
      assert.are.same({ "goodbye" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    end)

    it("discards formatting changes if buffer has been concurrently modified", function()
      run_formatter("hello", "goodbye", { async = true })
      assert.are.same({ "hello" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
      vim.api.nvim_buf_set_lines(0, 0, -1, true, { "newcontent" })
      vim.wait(1000, function()
        return vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == "newcontent"
      end)
      assert.are.same({ "newcontent" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    end)

    it("discards formatting changes if formatter output is empty /w non-empty input", function()
      local bufnr = vim.fn.bufadd("testfile")
      vim.fn.bufload(bufnr)
      vim.api.nvim_set_current_buf(bufnr)
      local original_lines = { "line one", "line two" }
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, original_lines)
      vim.bo[bufnr].modified = false
      set_formatter_output({ "" })
      conform.format({ formatters = { "test" }, quiet = true })
      local output_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.same(original_lines, output_lines)
    end)

    it("formats on save", function()
      conform.setup({
        formatters_by_ft = { ["*"] = { "test" } },
        format_on_save = true,
      })
      vim.cmd.edit({ args = { "tests/testfile.txt" } })
      vim.api.nvim_buf_set_lines(0, 0, -1, true, { "hello" })
      set_formatter_output({ "goodbye" })
      vim.cmd.write()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      vim.fn.delete("tests/testfile.txt")
      assert.are.same({ "goodbye" }, lines)
    end)

    it("formats file even if one formatter errors", function()
      conform.formatters.test2 = {
        command = "tests/fake_formatter.sh",
        args = { "--fail" },
      }
      local lines = run_formatter("hello", "goodbye", { formatters = { "test2", "test" } })
      assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    end)

    it("does not change output if dry_run is true", function()
      run_formatter("hello", "foo", { dry_run = true })
      assert.are.same({ "hello" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    end)

    describe("range formatting", function()
      it("applies edits that overlap the range start", function()
        run_formatter(
          "a\nb\nc",
          "d\nb\nd",
          { range = {
            start = { 1, 0 },
            ["end"] = { 2, 0 },
          } }
        )
        assert.are.same({ "d", "b", "c" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
      end)

      it("applies edits that overlap the range end", function()
        run_formatter(
          "a\nb\nc",
          "d\nb\nd",
          { range = {
            start = { 3, 0 },
            ["end"] = { 3, 1 },
          } }
        )
        assert.are.same({ "a", "b", "d" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
      end)

      it("applies edits that are completely contained by the range", function()
        run_formatter(
          "a\nb\nc",
          "a\nd\nc",
          { range = {
            start = { 1, 0 },
            ["end"] = { 3, 0 },
          } }
        )
        assert.are.same({ "a", "d", "c" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
      end)
    end)
  end)
end)
