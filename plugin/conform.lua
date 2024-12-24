vim.api.nvim_create_user_command("ConformInfo", function()
  require("conform.health").show_window()
end, { desc = "Show information about Conform formatters" })
