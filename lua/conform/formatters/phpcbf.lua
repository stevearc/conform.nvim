local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://phpqa.io/projects/phpcbf.html",
    description = "PHP Code Beautifier and Fixer fixes violations of a defined coding standard.",
  },
  command = util.find_executable({
    "vendor/bin/phpcbf",
  }, "phpcbf"),
  args = function(self, ctx)
    return { "-q", "--stdin-path=" .. ctx.filename, "-" }
  end,
  stdin = true,
  -- 0: no errors found
  -- 1: errors found
  -- 2: fixable errors found
  -- 3: processing error
  exit_codes = { 0, 1, 2 },
}
