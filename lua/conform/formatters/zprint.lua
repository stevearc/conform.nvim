---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/kkinnear/zprint",
    description = "Formatter for Clojure and EDN.",
  },
  command = "zprint",
  range_args = function(self, ctx)
    return {
      string.format(
        "{:input {:range {:start %d :end %d :use-previous-!zprint? true :continue-after-!zprint-error? true}}}",
        ctx.range.start[1] - 1,
        ctx.range["end"][1] - 1
      ),
    }
  end,
}
