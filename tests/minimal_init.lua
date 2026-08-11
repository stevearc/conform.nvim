vim.cmd([[set runtimepath+=.]])

-- Allow `require("tests.*")` from this repo root.
do
  local cwd = vim.fn.getcwd()
  package.path = table.concat({
    package.path,
    cwd .. "/?.lua",
    cwd .. "/?/init.lua",
  }, ";")
end

vim.o.swapfile = false
vim.bo.swapfile = false
require("tests.test_util").reset_editor()

local ts = require("nvim-treesitter")
ts.install({ "markdown", "markdown_inline", "lua", "typescript", "html", "nix", "rust", "bash" }):wait(30000)

vim.api.nvim_create_user_command("RunTests", function(opts)
  local path = opts.fargs[1] or "tests"
  require("plenary.test_harness").test_directory(
    path,
    { minimal_init = "./tests/minimal_init.lua" }
  )
end, { nargs = "?" })
