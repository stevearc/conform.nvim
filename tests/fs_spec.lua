local fs = require("conform.fs")

describe("fs", function()
  local relative_paths = {
    { "/home", "/home/file.txt", "file.txt" },
    { "/home/", "/home/file.txt", "file.txt" },
    { "/home", "/foo/file.txt", "../foo/file.txt" },
    { "/home/foo", "/home/bar/file.txt", "../bar/file.txt" },
    { "/home", "/file.txt", "../file.txt" },
    { "/home", "/home/foo/file.txt", "foo/file.txt" },
    { ".", "foo/file.txt", "foo/file.txt" },
    { "home", "home/file.txt", "file.txt" },
    { "home", "file.txt", "../file.txt" },
  }

  it("relative_path", function()
    for _, paths in ipairs(relative_paths) do
      local source, target, expected = unpack(paths)
      assert.are.same(fs.relative_path(source, target), expected)
    end
  end)
end)
