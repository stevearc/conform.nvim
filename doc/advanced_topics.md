# Advanced topics

<!-- TOC -->

- [Minimal format diffs](#minimal-format-diffs)
- [Range formatting](#range-formatting)
- [Injected language formatting (code blocks)](#injected-language-formatting-code-blocks)

<!-- /TOC -->

## Minimal format diffs

To understand why this is important and why conform.nvim is different we need a bit of historical context. Formatting tools work by taking in the current state of the file and outputting the same contents, with formatting applied. The way most formatting plugins work is they take the new content and replace the entire buffer. The benefit of this approach is that it's very simple. It's easy to code, it's easy to reason about, and it's easy to debug.

What conform does differently is it leverages `:help vim.diff`, Neovim's lua bindings for xdiff. We use this to compare the formatted lines to the original content and calculate minimal chunks where changes need to be applied. From there, we convert these chunks into LSP TextEdit objects and use `vim.lsp.util.apply_text_edits()` to actually apply the changes. Since we're using the built-in LSP utility, we get the benefits of all the work that was put into improving the LSP formatting experience, such as the preservation of extmarks. The piecewise update also does a better job of preserving cursor position, folds, viewport position, etc.

## Range formatting

When a formatting tool doesn't have built-in support for range formatting, conform will attempt to "fake it" when requested. This is necessarily a **best effort** operation and is **not** guaranteed to be correct or error-free, however in _most_ cases it should produce acceptable results.

The way this "aftermarket" range formatting works is conform will format the entire buffer as per usual, but during the diff process it will discard diffs that fall outside of the selected range. This usually approximates a correct result, but as you can guess it's possible for the formatting to exceed the range (if the diff covering the range is large) or for the results to be incorrect (if the formatting changes require two diffs in different locations to be semantically correct).

## Injected language formatting (code blocks)

Requires: Neovim 0.9+

Sometimes you may have a file that contains small chunks of code in another language. This is most common for markup formats like markdown and neorg, but can theoretically be present in any filetype (for example, embedded SQL queries in a host language). For files like this, it would be nice to be able to format these code chunks using their language-specific formatters.

The way that conform supports this is via the `injected` formatter. If you run this formatter on a file, it will use treesitter to parse out the blocks in the file that have different languages and runs the formatters for that filetype (configured with `formatters_by_ft`). The formatters are run in parallel, one job for each language block.

This formatter is experimental; the behavior and configuration options are still subject to change. The current list of configuration options can be found at [formatter options](formatter_options.md#injected)
