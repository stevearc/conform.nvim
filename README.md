# conform.nvim

Formatter plugin for Neovim

<!-- TOC -->

- [Requirements](#requirements)
- [Installation](#installation)
- [Setup](#setup)
- [Formatters](#formatters)
- [Custom formatters](#custom-formatters)
- [API](#api)
  - [format(opts)](#formatopts)
  - [list_formatters(bufnr)](#list_formattersbufnr)
  - [list_all_formatters()](#list_all_formatters)
- [Acknowledgements](#acknowledgements)

<!-- /TOC -->

## Requirements

- Neovim 0.8+

## Installation

conform.nvim supports all the usual plugin managers

<details>
  <summary>lazy.nvim</summary>

```lua
{
  'stevearc/conform.nvim',
  opts = {},
}
```

</details>

<details>
  <summary>Packer</summary>

```lua
require('packer').startup(function()
    use {
      'stevearc/conform.nvim',
      config = function() require('conform').setup() end
    }
end)
```

</details>

<details>
  <summary>Paq</summary>

```lua
require "paq" {
    {'stevearc/conform.nvim'};
}
```

</details>

<details>
  <summary>vim-plug</summary>

```vim
Plug 'stevearc/conform.nvim'
```

</details>

<details>
  <summary>dein</summary>

```vim
call dein#add('stevearc/conform.nvim')
```

</details>

<details>
  <summary>Pathogen</summary>

```sh
git clone --depth=1 https://github.com/stevearc/conform.nvim.git ~/.vim/bundle/
```

</details>

<details>
  <summary>Neovim native package</summary>

```sh
git clone --depth=1 https://github.com/stevearc/conform.nvim.git \
  "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/conform/start/conform.nvim
```

</details>

## Setup

At a minimum, you will need to set up some formatters by filetype

```lua
require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will use the first available formatter in the list
        javascript = { "prettier_d", "prettier" },
        -- Formatters can also be specified with additional options
        python = {
            formatters = { "isort", "black" },
            -- Run formatters one after another instead of stopping at the first success
            run_all_formatters = true,
            -- Don't run these formatters as part of the format_on_save autocmd (see below)
            format_on_save = false
        },
    },
})
```

You can also modify `formatters_by_ft` directly

```lua
require("conform").formatters_by_ft.lua = { "stylua" }
```

Then you can use `conform.format()` just like you would `vim.lsp.buf.format()`. For example, to format on save:

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        require("conform").format({ buf = args.buf })
    end,
})
```

As a shortcut, conform will optionally set up this format-on-save autocmd for you

```lua
require("conform").setup({
    format_on_save = true,
})
```

You can also use an option table and it will get passed to `conform.format()`

```lua
require("conform").setup({
    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
    },
})
```

See [conform.format()](#formatopts) for more details about capabilities and parameters.

To view configured and available formatters, as well as to see the path to the log file, run `:checkhealth conform`

## Formatters

<!-- FORMATTERS -->

- [autoflake](https://github.com/PyCQA/autoflake) - Removes unused imports and unused variables as reported by pyflakes.
- [autopep8](https://github.com/hhatto/autopep8) - A tool that automatically formats Python code to conform to the PEP 8 style guide.
- [black](https://github.com/psf/black) - The uncompromising Python code formatter.
- [clang_format](https://www.kernel.org/doc/html/latest/process/clang-format.html) - Tool to format C/C++/… code according to a set of rules and heuristics.
- [cljstyle](https://github.com/greglook/cljstyle) - Formatter for Clojure code.
- [cmake_format](https://github.com/cheshirekow/cmake_format) - Parse cmake listfiles and format them nicely.
- [dart_format](https://dart.dev/tools/dart-format) - Replace the whitespace in your program with formatting that follows Dart guidelines.
- [dfmt](https://github.com/dlang-community/dfmt) - Formatter for D source code.
- [elm_format](https://github.com/avh4/elm-format) - elm-format formats Elm source code according to a standard set of rules based on the official [Elm Style Guide](https://elm-lang.org/docs/style-guide).
- [erb_format](https://github.com/nebulab/erb-formatter) - Format ERB files with speed and precision.
- [eslint_d](https://github.com/mantoni/eslint_d.js/) - Like ESLint, but faster.
- [gdformat](https://github.com/Scony/godot-gdscript-toolkit) - A formatter for Godot's gdscript.
- [gofmt](https://pkg.go.dev/cmd/gofmt) - Formats go programs.
- [gofumpt](https://github.com/mvdan/gofumpt) - Enforce a stricter format than gofmt, while being backwards compatible. That is, gofumpt is happy with a subset of the formats that gofmt is happy with.
- [goimports](https://pkg.go.dev/golang.org/x/tools/cmd/goimports) - Updates your Go import lines, adding missing ones and removing unreferenced ones.
- [htmlbeautifier](https://github.com/threedaymonk/htmlbeautifier) - A normaliser/beautifier for HTML that also understands embedded Ruby. Ideal for tidying up Rails templates.
- [isort](https://github.com/PyCQA/isort) - Python utility / library to sort imports alphabetically and automatically separate them into sections and by type.
- [jq](https://github.com/stedolan/jq) - Command-line JSON processor.
- [nixfmt](https://github.com/serokell/nixfmt) - nixfmt is a formatter for Nix code, intended to apply a uniform style.
- [nixpkgs_fmt](https://github.com/nix-community/nixpkgs-fmt) - nixpkgs-fmt is a Nix code formatter for nixpkgs.
- [ocamlformat](https://github.com/ocaml-ppx/ocamlformat) - Auto-formatter for OCaml code.
- [pg_format](https://github.com/darold/pgFormatter) - PostgreSQL SQL syntax beautifier.
- [prettier](https://github.com/prettier/prettier) - Prettier is an opinionated code formatter. It enforces a consistent style by parsing your code and re-printing it with its own rules that take the maximum line length into account, wrapping code when necessary.
- [prettierd](https://github.com/fsouza/prettierd) - prettier, as a daemon, for ludicrous formatting speed.
- [rubocop](https://github.com/rubocop/rubocop) - Ruby static code analyzer and formatter, based on the community Ruby style guide.
- [rustfmt](https://github.com/rust-lang/rustfmt) - A tool for formatting rust code according to style guidelines.
- [scalafmt](https://github.com/scalameta/scalafmt) - Code formatter for Scala.
- [shfmt](https://github.com/mvdan/sh) - A shell parser, formatter, and interpreter with `bash` support.
- [sql_formatter](https://github.com/sql-formatter-org/sql-formatter) - A whitespace formatter for different query languages.
- [stylua](https://github.com/JohnnyMorganz/StyLua) - An opinionated code formatter for Lua.
- [swift_format](https://github.com/apple/swift-format) - Swift formatter from apple. Requires building from source with `swift build`.
- [swiftformat](https://github.com/nicklockwood/SwiftFormat) - SwiftFormat is a code library and command-line tool for reformatting `swift` code on macOS or Linux.
- [terraform_fmt](https://www.terraform.io/docs/cli/commands/fmt.html) - The terraform-fmt command rewrites `terraform` configuration files to a canonical format and style.
- [uncrustify](https://github.com/uncrustify/uncrustify) - A source code beautifier for C, C++, C#, ObjectiveC, D, Java, Pawn and Vala.
- [xmlformat](https://github.com/pamoller/xmlformatter) - xmlformatter is an Open Source Python package, which provides formatting of XML documents.
- [yamlfix](https://github.com/lyz-code/yamlfix) - A configurable YAML formatter that keeps comments.
- [yamlfmt](https://github.com/google/yamlfmt) - yamlfmt is an extensible command line tool or library to format yaml files.
- [yapf](https://github.com/google/yapf) - Yet Another Python Formatter.
- [zigfmt](https://github.com/ziglang/zig) - Reformat Zig source into canonical form.
<!-- /FORMATTERS -->

## Custom formatters

You can create your own custom formatters

```lua
require("conform").setup({
    formatters = {
        my_formatter = {
            -- This can be a string or a function that returns a string
            command = 'my_cmd',
            -- OPTIONAL - all fields below this are optional
            -- A list of strings, or a function that returns a list of strings
            args = { "--stdin-from-filename", "$FILENAME" },
            -- Send file contents to stdin, read new contents from stdout (default true)
            -- When false, will create a temp file (will appear in "$FILENAME" args). The temp
            -- file is assumed to be modified in-place by the format command.
            stdin = true,
            -- A function the calculates the directory to run the command in
            cwd = require("conform.util").root_file({ ".editorconfig", "package.json" }),
            -- When cwd is not found, don't run the formatter (default false)
            require_cwd = true,
            -- When returns false, the formatter will not be used
            condition = function(ctx)
                return vim.fs.basename(ctx.filename) ~= "README.md"
            end,
            -- Exit codes that indicate success (default {0})
            exit_codes = { 0, 1 },
        }
    }
})
```

Again, you can also set these directly

```lua
require("conform").formatters.my_formatter = { ... }
```

## API

<!-- API -->

### format(opts)

`format(opts): boolean` \
Format a buffer

| Param | Type         | Desc            |                                                                                            |
| ----- | ------------ | --------------- | ------------------------------------------------------------------------------------------ |
| opts  | `nil\|table` |                 |                                                                                            |
|       | timeout_ms   | `nil\|integer`  | Time in milliseconds to block for formatting. Defaults to 1000. No effect if async = true. |
|       | bufnr        | `nil\|integer`  | Format this buffer (default 0)                                                             |
|       | async        | `nil\|boolean`  | If true the method won't block. Defaults to false.                                         |
|       | formatters   | `nil\|string[]` | List of formatters to run. Defaults to all formatters for the buffer filetype.             |
|       | lsp_fallback | `nil\|boolean`  | Attempt LSP formatting if no formatters are available. Defaults to false.                  |

Returns:
| Type    | Desc                                  |
| ------- | ------------------------------------- |
| boolean | True if any formatters were attempted |

### list_formatters(bufnr)

`list_formatters(bufnr): conform.FormatterInfo[]` \
Retried the available formatters for a buffer

| Param | Type           | Desc |
| ----- | -------------- | ---- |
| bufnr | `nil\|integer` |      |

### list_all_formatters()

`list_all_formatters(): conform.FormatterInfo[]` \
List information about all filetype-configured formatters

<!-- /API -->

## Acknowledgements

Thanks to

- [nvim-lint](https://github.com/mfussenegger/nvim-lint) for providing inspiration for the config and API. It's an excellent plugin that balances power and simplicity.
- [null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim) for formatter configurations and being my formatter/linter of choice for a long time.
