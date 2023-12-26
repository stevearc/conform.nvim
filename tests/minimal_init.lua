vim.cmd([[set runtimepath+=.]])

vim.o.swapfile = false
vim.bo.swapfile = false
require("tests.test_util").reset_editor()

local configs = require("nvim-treesitter.configs")
configs.setup({
  ensure_installed = { "markdown", "markdown_inline", "lua", "typescript", "html" },
  sync_install = true,
})
-- this needs to be run a second time to make tests behave
require("nvim-treesitter").setup()

vim.api.nvim_create_user_command("RunTests", function(opts)
  local path = opts.fargs[1] or "tests"
  require("plenary.test_harness").test_directory(
    path,
    { minimal_init = "./tests/minimal_init.lua" }
  )
end, { nargs = "?" })
