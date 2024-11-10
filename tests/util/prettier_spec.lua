require("plenary.async").tests.add_to_env()

local test_util = require("tests.test_util")
local util = require("conform.util")

local TMP_DIR = "./tmp/formatters/prettier/"

describe("util/prettier", function()
  before_each(function()
    vim.fn.mkdir(TMP_DIR, "p")
  end)

  after_each(function()
    test_util.reset_editor()

    vim.fn.delete(TMP_DIR, "rf")
  end)

  describe("cwd", function()
    it("has no marker", function()
      vim.fn.writefile({ "{}" }, vim.fs.joinpath(TMP_DIR, "package.json"))
      local jsfile = vim.fs.joinpath(TMP_DIR, "some.js")
      vim.fn.writefile({ "" }, jsfile)

      local cwd = util.prettier_cwd({}, { dirname = vim.fn.fnamemodify(jsfile, ":p:h") })

      assert.equal(nil, cwd)
    end)

    describe("config file", function()
      it("recognizes prettier config file", function()
        vim.fn.writefile({ "" }, vim.fs.joinpath(TMP_DIR, ".prettierrc"))
        local jsfile = vim.fs.joinpath(TMP_DIR, "some.js")
        vim.fn.writefile({ "" }, jsfile)

        local cwd = util.prettier_cwd({}, { dirname = vim.fn.fnamemodify(jsfile, ":p:h") })

        assert.equal(vim.fn.fnamemodify(jsfile, ":p:h"), cwd)
      end)

      it("looks up recursively", function()
        vim.fn.writefile({ "" }, vim.fs.joinpath(TMP_DIR, ".prettierrc"))

        local nested_dir = vim.fs.joinpath(TMP_DIR, "nested")
        vim.fn.mkdir(nested_dir, "p")
        vim.fn.writefile({ "{}" }, vim.fs.joinpath(nested_dir, "package.json"))

        local jsfile = vim.fs.joinpath(nested_dir, "some.js")
        vim.fn.writefile({ "" }, jsfile)

        local cwd = util.prettier_cwd({}, { dirname = vim.fn.fnamemodify(jsfile, ":p:h") })

        assert.equal(vim.fn.fnamemodify(TMP_DIR, ":p:h"), cwd)
      end)
    end)

    describe("package.json", function()
      it("handles syntax error", function()
        vim.fn.writefile({ "plain text" }, vim.fs.joinpath(TMP_DIR, "package.json"))
        local jsfile = vim.fs.joinpath(TMP_DIR, "some.js")
        vim.fn.writefile({ "" }, jsfile)

        local log = {}
        require("conform.log").set_handler(function(text)
          table.insert(log, text)
        end)

        local cwd = util.prettier_cwd({}, { dirname = vim.fn.fnamemodify(jsfile, ":p:h") })

        assert.equal(nil, cwd)

        assert.is_true(#log == 1)

        assert.no_nil(string.find(log[1], "[ERROR] Unable to parse json file", 1, true))
      end)

      it("recognizes prettier field", function()
        vim.fn.writefile({ '{"prettier": {}}' }, vim.fs.joinpath(TMP_DIR, "package.json"))
        local jsfile = vim.fs.joinpath(TMP_DIR, "some.js")
        vim.fn.writefile({ "" }, jsfile)

        local cwd = util.prettier_cwd({}, { dirname = vim.fn.fnamemodify(jsfile, ":p:h") })

        assert.equal(vim.fn.fnamemodify(jsfile, ":p:h"), cwd)
      end)

      -- test it explicitly just for a future traveler's clarity
      it("ignores prettier dependency", function()
        vim.fn.writefile(
          { '{"dependencies": {"prettier": "1.1.1"}, "devDependencies": {"prettier": "1.1.1"}}' },
          vim.fs.joinpath(TMP_DIR, "package.json")
        )
        local jsfile = vim.fs.joinpath(TMP_DIR, "some.js")
        vim.fn.writefile({ "" }, jsfile)

        local cwd = util.prettier_cwd({}, { dirname = vim.fn.fnamemodify(jsfile, ":p:h") })

        assert.equal(nil, cwd)
      end)

      it("looks up recursively", function()
        vim.fn.writefile({ '{"prettier": {}}' }, vim.fs.joinpath(TMP_DIR, "package.json"))

        local nested_dir = vim.fs.joinpath(TMP_DIR, "nested")
        vim.fn.mkdir(nested_dir, "p")
        vim.fn.writefile({ "{}" }, vim.fs.joinpath(nested_dir, "package.json"))

        local jsfile = vim.fs.joinpath(nested_dir, "some.js")
        vim.fn.writefile({ "" }, jsfile)

        local cwd = util.prettier_cwd({}, { dirname = vim.fn.fnamemodify(jsfile, ":p:h") })

        assert.equal(vim.fn.fnamemodify(TMP_DIR, ":p:h"), cwd)
      end)
    end)

    it("stops on the first found marker", function()
      vim.fn.writefile({ '{"prettier": {}}' }, vim.fs.joinpath(TMP_DIR, "package.json"))

      local nested_dir = vim.fs.joinpath(TMP_DIR, "nested")
      vim.fn.mkdir(nested_dir, "p")
      vim.fn.writefile({ '{"prettier": {}}' }, vim.fs.joinpath(nested_dir, "package.json"))

      local jsfile = vim.fs.joinpath(nested_dir, "some.js")
      vim.fn.writefile({ "" }, jsfile)

      local cwd = util.prettier_cwd({}, { dirname = vim.fn.fnamemodify(jsfile, ":p:h") })

      assert.equal(vim.fn.fnamemodify(jsfile, ":p:h"), cwd)
    end)
  end)
end)
