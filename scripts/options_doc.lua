require("conform").setup({
  -- Map of filetype to formatters
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will use the first available formatter in the list
    javascript = { "prettierd", "prettier" },
    -- Formatters can also be specified with additional options
    python = {
      formatters = { "isort", "black" },
      -- Run formatters one after another instead of stopping at the first success
      run_all_formatters = true,
      -- Don't run these formatters as part of the format_on_save autocmd (see below)
      format_on_save = false,
    },
  },
  -- If this is set, Conform will run the formatter on save.
  -- It will pass the table to conform.format().
  format_on_save = {
    -- I recommend these options. See :help conform.format for details.
    lsp_fallback = true,
    timeout_ms = 500,
  },
  -- Set the log level. Use `:ConformInfo` to see the location of the log file.
  log_level = vim.log.levels.ERROR,
  -- Conform will notify you when a formatter errors
  notify_on_error = true,
  -- Define custom formatters here
  formatters = {
    my_formatter = {
      -- This can be a string or a function that returns a string
      command = "my_cmd",
      -- OPTIONAL - all fields below this are optional
      -- A list of strings, or a function that returns a list of strings
      args = { "--stdin-from-filename", "$FILENAME" },
      -- If the formatter supports range formatting, create the range arguments here
      range_args = function(ctx)
        return { "--line-start", ctx.range.start[1], "--line-end", ctx.range["end"][1] }
      end,
      -- Send file contents to stdin, read new contents from stdout (default true)
      -- When false, will create a temp file (will appear in "$FILENAME" args). The temp
      -- file is assumed to be modified in-place by the format command.
      stdin = true,
      -- A function the calculates the directory to run the command in
      cwd = require("conform.util").root_file({ ".editorconfig", "package.json" }),
      -- When cwd is not found, don't run the formatter (default false)
      require_cwd = true,
      -- When returns false, the formatter will not be used
      condition = function(ctx)
        return vim.fs.basename(ctx.filename) ~= "README.md"
      end,
      -- Exit codes that indicate success (default {0})
      exit_codes = { 0, 1 },
      -- Environment variables. This can also be a function that returns a table.
      env = {
        VAR = "value",
      },
    },
    -- These can also be a function that returns the formatter
    other_formatter = function()
      return {
        command = "my_cmd",
      }
    end,
  },
})

-- You can set formatters_by_ft and formatters directly
require("conform").formatters_by_ft.lua = { "stylua" }
require("conform").formatters.my_formatter = {
  command = "my_cmd",
}
