-- yew-fmt is a fork of rustfmt
local conf = vim.deepcopy(require("conform.formatters.rustfmt"))

conf.meta = {
  url = "https://github.com/schvv31n/yew-fmt",
  description = "Code formatter for the Yew framework.",
}

conf.command = "yew-fmt"

return conf
