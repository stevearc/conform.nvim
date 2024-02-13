-- The formatter expects one of [.res | .resi | .ml | .mli] passed as
-- the value to the '-stdin' argument.
local valid_extensions = {
  res = true,
  resi = true,
  ml = true,
  mli = true,
}

local default_extension = "res"

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://rescript-lang.org/",
    description = "The built-in ReScript formatter.",
  },
  command = "rescript",
  args = function(self, ctx)
    local extension = vim.fn.fnamemodify(ctx.filename, ":e")

    local is_invalid_extension = valid_extensions[extension] == nil
    if is_invalid_extension then
      extension = default_extension
    end

    return {
      "format",
      "-stdin",
      "." .. extension,
    }
  end,
  stdin = true,

  require_cwd = true,
  cwd = require("conform.util").root_file({
    "rescript.json",
    "bsconfig.json",
  }),
}
