local util = require("conform.util")

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/VincentLanglet/Twig-CS-Fixer",
    description = "Automatically fix Twig Coding Standards issues",
  },
  command = util.find_executable({
    "vendor/bin/twig-cs-fixer",
  }, "twig-cs-fixer"),
  args = { "lint", "$FILENAME", "--fix", "--no-interaction", "--quiet" },
  cwd = util.root_file({
    ".twig-cs-fixer.php",
    ".twig-cs-fixer.dist.php",
    "composer.json",
  }),
  require_cwd = false,
  stdin = false,
}
