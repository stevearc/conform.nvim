return {
  meta = {
    url = "https://hackage.haskell.org/package/cabal-fmt",
    description = "Format cabal files with cabal-fmt.",
  },
  command = "cabal-fmt",
  args = { "--inplace", "$FILENAME" },
  stdin = false,
}
