---@type conform.FileFormatterConfig
return {
  meta = {
    url = "http://xmlstar.sourceforge.net/",
    description = "XMLStarlet is a command-line XML toolkit that can be used to format XML files.",
  },
  command = "xmlstarlet",
  args = { "format", "--indent-spaces", "2", "-" },
}
