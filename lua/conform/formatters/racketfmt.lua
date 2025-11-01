---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://docs.racket-lang.org/fmt",
    description = "Racket language formatter, installed by `raco pkg install fmt`.",
  },
  command = "raco",
  args = { "fmt" },
}
