local dir_manager = require("conform.dir_manager")
local test_util = require("tests.test_util")

local function touch(path)
  local fd = assert(vim.uv.fs_open(path, "w", 448))
  vim.uv.fs_write(fd, "")
  vim.uv.fs_close(fd)
end

describe("dir_manager", function()
  after_each(function()
    test_util.reset_editor()
  end)

  it("creates and cleans up nested created directories", function()
    local root, err = vim.uv.fs_mkdtemp("conform_XXXXXX")
    assert(root, err)
    dir_manager.ensure_parent(root .. "/foo/bar/baz.txt")
    assert(vim.uv.fs_stat(root .. "/foo"))
    assert(vim.uv.fs_stat(root .. "/foo/bar"))
    assert(not vim.uv.fs_stat(root .. "/foo/bar/baz.txt"))
    dir_manager.cleanup()
    assert(not vim.uv.fs_stat(root .. "/foo/bar"))
    assert(not vim.uv.fs_stat(root .. "/foo"))
    assert(vim.uv.fs_stat(root))
    assert(vim.uv.fs_rmdir(root))
  end)

  it("handles race condition for two concurrent processes", function()
    local root, err = vim.uv.fs_mkdtemp("conform_XXXXXX")
    assert(root, err)
    dir_manager.ensure_parent(root .. "/foo/bar/baz.txt")
    touch(root .. "/foo/bar/baz.txt")
    assert(vim.uv.fs_stat(root .. "/foo"))
    assert(vim.uv.fs_stat(root .. "/foo/bar"))
    assert(vim.uv.fs_stat(root .. "/foo/bar/baz.txt"))

    -- This cleanup will fail because baz.txt exists
    dir_manager.cleanup()
    assert(vim.uv.fs_stat(root .. "/foo/bar/baz.txt"))

    assert(vim.uv.fs_unlink(root .. "/foo/bar/baz.txt"))
    -- This cleanup should succeed
    dir_manager.cleanup()
    assert(not vim.uv.fs_stat(root .. "/foo/bar"))
    assert(not vim.uv.fs_stat(root .. "/foo"))

    assert(vim.uv.fs_stat(root))
    assert(vim.uv.fs_rmdir(root))
  end)

  it("handles race condition for semi-matched nested paths", function()
    local root, err = vim.uv.fs_mkdtemp("conform_XXXXXX")
    assert(root, err)
    dir_manager.ensure_parent(root .. "/foo/bar/baz.txt")
    dir_manager.ensure_parent(root .. "/foo/qux/foo.txt")
    touch(root .. "/foo/qux/foo.txt")
    assert(vim.uv.fs_stat(root .. "/foo"))
    assert(vim.uv.fs_stat(root .. "/foo/bar"))
    assert(vim.uv.fs_stat(root .. "/foo/qux"))
    assert(vim.uv.fs_stat(root .. "/foo/qux/foo.txt"))

    -- This cleanup will partially succeed because foo.txt exists
    dir_manager.cleanup()
    assert(vim.uv.fs_stat(root .. "/foo"))
    assert(not vim.uv.fs_stat(root .. "/bar"))
    assert(vim.uv.fs_stat(root .. "/foo/qux"))
    assert(vim.uv.fs_stat(root .. "/foo/qux/foo.txt"))

    assert(vim.uv.fs_unlink(root .. "/foo/qux/foo.txt"))
    -- This cleanup should succeed
    dir_manager.cleanup()
    assert(not vim.uv.fs_stat(root .. "/foo/qux"))
    assert(not vim.uv.fs_stat(root .. "/foo"))

    assert(vim.uv.fs_stat(root))
    assert(vim.uv.fs_rmdir(root))
  end)
end)
