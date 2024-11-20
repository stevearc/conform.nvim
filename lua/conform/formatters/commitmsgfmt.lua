---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://gitlab.com/mkjeldsen/commitmsgfmt",
    description = "Formats commit messages better than fmt(1) and Vim.",
  },
  command = "commitmsgfmt",
  stdin = true,
}
