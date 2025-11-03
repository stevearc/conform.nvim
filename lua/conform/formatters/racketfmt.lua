---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://docs.racket-lang.org/fmt",
    description = "Racket language formatter.",
  },
  command = "raco",
  args = { "fmt" },
}
