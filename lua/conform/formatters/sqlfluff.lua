local log = require("conform.log")
local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/sqlfluff/sqlfluff",
    description = "A modular SQL linter and auto-formatter with support for multiple dialects and templated code.",
  },
  options = {
    -- Fallback dialect when no SQLFluff configuration file is found.
    -- Supported dialects: https://docs.sqlfluff.com/en/stable/reference/dialects/
    dialect = "",
  },
  command = "sqlfluff",
  args = function(cfg, ctx)
    -- A project config exists; let SQLFluff handle dialect detection.
    if cfg.cwd(cfg, ctx) then
      return { "fix", "-" }
    end

    local dialect = cfg.options.dialect
    -- No project config; use the configured fallback dialect.
    if dialect and dialect ~= "" then
      return { "fix", "--dialect", dialect, "-" }
    end

    log.warn(
      "Unable to determine SQL dialect. "
        .. "No configuration file or fallback dialect was found. "
        .. "If you're using an in-file config directive, you can ignore this warning. "
        .. "Otherwise, set `options.dialect` or add a configuration file: "
        .. "https://docs.sqlfluff.com/en/stable/configuration/#configuration-files"
    )

    return { "fix", "-" }
  end,
  stdin = true,
  cwd = util.root_file({
    ".sqlfluff",
    "pep8.ini",
    "pyproject.toml",
    "setup.cfg",
    "tox.ini",
  }),
}
