vim.cmd([[set runtimepath+=.]])

vim.o.swapfile = false
vim.bo.swapfile = false
require("tests.test_util").reset_editor()

local ts = require("nvim-treesitter")
ts.install({ "markdown", "markdown_inline", "lua", "typescript", "html" }):wait(30000)

vim.api.nvim_create_user_command("RunTests", function(opts)
  local path = opts.fargs[1] or "tests"
  require("plenary.test_harness").test_directory(
    path,
    { minimal_init = "./tests/minimal_init.lua" }
  )
end, { nargs = "?" })
