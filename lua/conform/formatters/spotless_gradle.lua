---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/diffplug/spotless",
    description = "Spotless plugin for Gradle.",
  },
  stdin = true,
  require_cwd = true,
  cwd = require("conform.util").root_file({ "gradlew" }),
  command = "./gradlew",
  args = function(_, ctx)
    return {
      "spotlessApply",
      "-PspotlessIdeHook=" .. ctx.filename,
      "-PspotlessIdeHookUseStdIn",
      "-PspotlessIdeHookUseStdOut",
      "--no-configuration-cache",
      "--quiet",
    }
  end,
}
