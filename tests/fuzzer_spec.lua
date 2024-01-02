require("plenary.async").tests.add_to_env()
local conform = require("conform")
local log = require("conform.log")
local runner = require("conform.runner")
local test_util = require("tests.test_util")

describe("fuzzer", function()
  before_each(function()
    conform.formatters.test = {
      meta = { url = "", description = "" },
      command = "tests/fake_formatter.sh",
    }
  end)

  after_each(function()
    test_util.reset_editor()
  end)

  ---@param buf_content string[]
  ---@param expected string[]
  ---@param opts? table
  local function run_formatter(buf_content, expected, opts)
    local bufnr = vim.fn.bufadd("testfile")
    vim.fn.bufload(bufnr)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, buf_content)
    vim.bo[bufnr].modified = false
    runner.apply_format(0, buf_content, expected, nil, false)
    assert.are.same(expected, vim.api.nvim_buf_get_lines(0, 0, -1, false))
  end

  local function make_word()
    local chars = {}
    for _ = 1, math.random(1, 10) do
      table.insert(chars, string.char(math.random(97, 122)))
    end
    return table.concat(chars, "")
  end

  local function make_line()
    local words = {}
    for _ = 1, math.random(0, 6) do
      table.insert(words, make_word())
    end
    return table.concat(words, " ")
  end

  local function make_file(num_lines)
    local lines = {}
    for _ = 1, math.random(1, num_lines) do
      table.insert(lines, make_line())
    end
    return lines
  end

  local function do_insert(lines)
    local idx = math.random(1, #lines + 1)
    for _ = 1, math.random(1, 3) do
      table.insert(lines, idx, make_line())
    end
  end

  local function do_replace(lines)
    local num_lines = math.random(1, math.min(3, #lines))
    local idx = math.random(1, #lines - num_lines + 1)
    local replacement = {}
    local num_replace = math.random(1, 5)
    for _ = 1, num_replace do
      table.insert(replacement, make_line())
    end
    local col = math.random(1, lines[idx]:len())
    replacement[1] = lines[idx]:sub(1, col) .. replacement[1]
    col = math.random(1, lines[idx + num_lines - 1]:len())
    replacement[#replacement] = replacement[#replacement] .. lines[idx + num_lines - 1]:sub(col)

    for _ = 1, num_lines - num_replace do
      table.remove(lines, idx)
    end
    for _ = 1, num_replace - num_lines do
      table.insert(lines, idx, "")
    end
    for i = 1, num_replace do
      lines[idx + i - 1] = replacement[i]
    end
  end

  local function do_delete(lines)
    local num_lines = math.random(1, 3)
    local idx = math.random(1, #lines - num_lines)
    for _ = 1, num_lines do
      table.remove(lines, idx)
    end
    -- vim will never let the lines be empty. An empty file has a single blank line.
    if #lines == 0 then
      table.insert(lines, "")
    end
  end

  local function make_edits(lines)
    local was_empty = table.concat(lines):match("^%s*$")
    lines = vim.deepcopy(lines)
    for _ = 1, math.random(0, 3) do
      do_insert(lines)
    end
    for _ = 1, math.random(0, 3) do
      do_replace(lines)
    end
    for _ = 1, math.random(0, 3) do
      do_delete(lines)
    end
    -- avoid blank output (whitepsace only) which is ignored when applying formatting
    if not was_empty then
      while table.concat(lines):match("^%s*$") do
        do_replace(lines)
      end
    end
    return lines
  end

  it("formats correctly", function()
    -- log.level = vim.log.levels.TRACE
    for i = 1, 50000 do
      math.randomseed(i)
      log.info("Fuzz testing with seed %d", i)
      local content = make_file(20)
      local formatted = make_edits(content)
      run_formatter(content, formatted)
    end
  end)
end)
