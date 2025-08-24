# conform.nvim

Lightweight yet powerful formatter plugin for Neovim

<!-- TOC -->

- [Requirements](#requirements)
- [Features](#features)
- [Installation](#installation)
- [Setup](#setup)
- [Formatters](#formatters)
- [Customizing formatters](#customizing-formatters)
  - [Magic strings](#magic-strings)
- [Recipes](#recipes)
- [Debugging](#debugging)
- [Advanced topics](#advanced-topics)
- [Options](#options)
- [Formatter options](#formatter-options)
- [API](#api)
  - [setup(opts)](#setupopts)
  - [format(opts, callback)](#formatopts-callback)
  - [list_formatters(bufnr)](#list_formattersbufnr)
  - [list_formatters_to_run(bufnr)](#list_formatters_to_runbufnr)
  - [list_all_formatters()](#list_all_formatters)
  - [get_formatter_info(formatter, bufnr)](#get_formatter_infoformatter-bufnr)
- [FAQ](#faq)
- [Acknowledgements](#acknowledgements)

<!-- /TOC -->

## Requirements

- Neovim 0.10+ (for older versions, use a [nvim-0.x branch](https://github.com/stevearc/conform.nvim/branches))

## Features

- **Preserves extmarks and folds** - Most formatters replace the entire buffer, which clobbers extmarks and folds, and can cause the viewport and cursor to jump unexpectedly. Conform calculates minimal diffs and applies them using the built-in LSP format utilities.
- **Fixes bad-behaving LSP formatters** - Some LSP servers are lazy and simply replace the entire buffer, leading to the problems mentioned above. Conform hooks into the LSP handler and turns these responses into proper piecewise changes.
- **Enables range formatting for all formatters** - Since conform calculates minimal diffs, it can perform range formatting [even if the underlying formatter doesn't support it.](doc/advanced_topics.md#range-formatting)
- **Simple API** - Conform exposes a simple, imperative API modeled after `vim.lsp.buf.format()`.
- **Formats embedded code blocks** - Can format code blocks inside markdown files or similar (see [injected language formatting](doc/advanced_topics.md#injected-language-formatting-code-blocks))

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

For a more thorough configuration involving lazy-loading, see [Lazy loading with lazy.nvim](doc/recipes.md#lazy-loading-with-lazynvim).

</details>

<details>
  <summary>Packer</summary>

```lua
require("packer").startup(function()
  use({
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup()
    end,
  })
end)
```

</details>

<details>
  <summary>Paq</summary>

```lua
require("paq")({
  { "stevearc/conform.nvim" },
})
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
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- You can customize some of the format options for the filetype (:help conform.format)
    rust = { "rustfmt", lsp_format = "fallback" },
    -- Conform will run the first available formatter
    javascript = { "prettierd", "prettier", stop_after_first = true },
  },
})
```

Then you can use `conform.format()` just like you would `vim.lsp.buf.format()`. For example, to format on save:

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
```

As a shortcut, conform will optionally set up this format-on-save autocmd for you

```lua
require("conform").setup({
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})
```

See [conform.format()](#formatopts-callback) for more details about the parameters.

Conform also provides a formatexpr, same as the LSP client:

```lua
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
```

To view configured and available formatters, as well as to see the log file, run `:ConformInfo`

## Formatters

You can view this list in vim with `:help conform-formatters`

<details>
  <summary>Expand to see all formatters</summary>

<!-- FORMATTERS -->

- [air](https://github.com/posit-dev/air) - R formatter and language server.
- [alejandra](https://kamadorueda.com/alejandra/) - The Uncompromising Nix Code Formatter.
- [ansible-lint](https://github.com/ansible/ansible-lint) - ansible-lint with --fix.
- [asmfmt](https://github.com/klauspost/asmfmt) - Go Assembler Formatter
- [ast-grep](https://ast-grep.github.io/) - A CLI tool for code structural search, lint and rewriting. Written in Rust.
- [astyle](https://astyle.sourceforge.net/astyle.html) - A Free, Fast, and Small Automatic Formatter for C, C++, C++/CLI, Objective-C, C#, and Java Source Code.
- [auto_optional](https://auto-optional.daanluttik.nl/) - Adds the Optional type-hint to arguments where the default value is None.
- [autocorrect](https://github.com/huacnlee/autocorrect) - A linter and formatter to help you to improve copywriting, correct spaces, words, and punctuations between CJK.
- [autoflake](https://github.com/PyCQA/autoflake) - Removes unused imports and unused variables as reported by pyflakes.
- [autopep8](https://github.com/hhatto/autopep8) - A tool that automatically formats Python code to conform to the PEP 8 style guide.
- [bean-format](https://beancount.github.io/docs/running_beancount_and_generating_reports.html#bean-format) - Reformat Beancount files to right-align all the numbers at the same, minimal column.
- [beautysh](https://github.com/lovesegfault/beautysh) - A Bash beautifier for the masses.
- [bibtex-tidy](https://github.com/FlamingTempura/bibtex-tidy) - Cleaner and Formatter for BibTeX files.
- [bicep](https://github.com/Azure/bicep) - Bicep is a Domain Specific Language (DSL) for deploying Azure resources declaratively.
- [biome](https://github.com/biomejs/biome) - A toolchain for web projects, aimed to provide functionalities to maintain them.
- [biome-check](https://github.com/biomejs/biome) - A toolchain for web projects, aimed to provide functionalities to maintain them.
- [biome-organize-imports](https://github.com/biomejs/biome) - A toolchain for web projects, aimed to provide functionalities to maintain them.
- [black](https://github.com/psf/black) - The uncompromising Python code formatter.
- [blade-formatter](https://github.com/shufo/blade-formatter) - An opinionated blade template formatter for Laravel that respects readability.
- [blue](https://github.com/grantjenks/blue) - The slightly less uncompromising Python code formatter.
- [bpfmt](https://source.android.com/docs/setup/reference/androidbp) - Android Blueprint file formatter.
- [bsfmt](https://github.com/rokucommunity/brighterscript-formatter) - A code formatter for BrighterScript (and BrightScript).
- [buf](https://buf.build/docs/reference/cli/buf/format) - A new way of working with Protocol Buffers.
- [buildifier](https://github.com/bazelbuild/buildtools/tree/master/buildifier) - buildifier is a tool for formatting bazel BUILD and .bzl files with a standard convention.
- [cabal_fmt](https://hackage.haskell.org/package/cabal-fmt) - Format cabal files with cabal-fmt.
- [caramel_fmt](https://caramel.run/manual/reference/cli/fmt.html) - Format Caramel code.
- [cbfmt](https://github.com/lukas-reineke/cbfmt) - A tool to format codeblocks inside markdown and org documents.
- [cedar](https://github.com/cedar-policy/cedar) - Formats cedar policies.
- [clang-format](https://clang.llvm.org/docs/ClangFormat.html) - Tool to format C/C++/… code according to a set of rules and heuristics.
- [cljfmt](https://github.com/weavejester/cljfmt) - cljfmt is a tool for detecting and fixing formatting errors in Clojure code.
- [cljstyle](https://github.com/greglook/cljstyle) - Formatter for Clojure code.
- [cmake_format](https://github.com/cheshirekow/cmake_format) - Parse cmake listfiles and format them nicely.
- [codeql](https://docs.github.com/en/code-security/codeql-cli/codeql-cli-manual/query-format) - Format queries and libraries with CodeQL.
- [codespell](https://github.com/codespell-project/codespell) - Check code for common misspellings.
- [commitmsgfmt](https://gitlab.com/mkjeldsen/commitmsgfmt) - Formats commit messages better than fmt(1) and Vim.
- [crlfmt](https://github.com/cockroachdb/crlfmt) - Formatter for CockroachDB's additions to the Go style guide.
- [crystal](https://crystal-lang.org/) - Format Crystal code.
- [csharpier](https://github.com/belav/csharpier) - The opinionated C# code formatter.
- [css_beautify](https://github.com/beautifier/js-beautify) - Beautifier for css.
- [cue_fmt](https://cuelang.org) - Format CUE files using `cue fmt` command.
- [d2](https://github.com/terrastruct/d2) - D2 is a modern diagram scripting language that turns text to diagrams.
- [darker](https://github.com/akaihola/darker) - Run black only on changed lines.
- [dart_format](https://dart.dev/tools/dart-format) - Replace the whitespace in your program with formatting that follows Dart guidelines.
- [dcm_fix](https://dcm.dev/docs/cli/formatting/fix/) - Fixes issues produced by dcm analyze, dcm check-unused-code or dcm check-dependencies commands.
- [dcm_format](https://dcm.dev/docs/cli/formatting/format/) - Formats .dart files.
- [deno_fmt](https://deno.land/manual/tools/formatter) - Use [Deno](https://deno.land/) to format TypeScript, JavaScript/JSON and markdown.
- [dfmt](https://github.com/dlang-community/dfmt) - Formatter for D source code.
- [dioxus](https://github.com/dioxuslabs/dioxus) - Format `rsx!` snippets in Rust files.
- [djlint](https://github.com/Riverside-Healthcare/djLint) - ✨ HTML Template Linter and Formatter. Django - Jinja - Nunjucks - Handlebars - GoLang.
- [docformatter](https://pypi.org/project/docformatter/) - docformatter automatically formats docstrings to follow a subset of the PEP 257 conventions.
- [docstrfmt](https://github.com/LilSpazJoekp/docstrfmt) - reStructuredText formatter.
- [doctoc](https://github.com/thlorenz/doctoc) - Generates table of contents for markdown files inside local git repository.
- [dprint](https://github.com/dprint/dprint) - Pluggable and configurable code formatting platform written in Rust.
- [easy-coding-standard](https://github.com/easy-coding-standard/easy-coding-standard) - ecs - Use Coding Standard with 0-knowledge of PHP-CS-Fixer and PHP_CodeSniffer.
- [efmt](https://github.com/sile/efmt) - Erlang code formatter.
- [elm_format](https://github.com/avh4/elm-format) - elm-format formats Elm source code according to a standard set of rules based on the official [Elm Style Guide](https://elm-lang.org/docs/style-guide).
- [erb_format](https://github.com/nebulab/erb-formatter) - Format ERB files with speed and precision.
- [erlfmt](https://github.com/WhatsApp/erlfmt) - An automated code formatter for Erlang.
- [eslint_d](https://github.com/mantoni/eslint_d.js/) - Like ESLint, but faster.
- [fantomas](https://github.com/fsprojects/fantomas) - F# source code formatter.
- [findent](https://github.com/wvermin/findent) - Indent, relabel and convert Fortran sources.
- [fish_indent](https://fishshell.com/docs/current/cmds/fish_indent.html) - Indent or otherwise prettify a piece of fish code.
- [fixjson](https://github.com/rhysd/fixjson) - JSON Fixer for Humans using (relaxed) JSON5.
- [fnlfmt](https://git.sr.ht/~technomancy/fnlfmt) - A formatter for Fennel code.
- [forge_fmt](https://github.com/foundry-rs/foundry) - Forge is a command-line tool that ships with Foundry. Forge tests, builds, and deploys your smart contracts.
- [format-dune-file](https://github.com/ocaml/dune) - Auto-formatter for Dune files.
- [format-queries](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/CONTRIBUTING.md#formatting) - Tree-sitter query formatter.
- [fourmolu](https://hackage.haskell.org/package/fourmolu) - A fork of ormolu that uses four space indentation and allows arbitrary configuration.
- [fprettify](https://github.com/fortran-lang/fprettify) - Auto-formatter for modern fortran source code.
- [gawk](https://www.gnu.org/software/gawk/manual/gawk.html) - Format awk programs with gawk.
- [gci](https://github.com/daixiang0/gci) - GCI, a tool that controls Go package import order and makes it always deterministic.
- [gdformat](https://github.com/Scony/godot-gdscript-toolkit) - A formatter for Godot's gdscript.
- [gersemi](https://github.com/BlankSpruce/gersemi) - A formatter to make your CMake code the real treasure.
- [ghokin](https://github.com/antham/ghokin) - Parallelized formatter with no external dependencies for gherkin.
- [gleam](https://github.com/gleam-lang/gleam) - ⭐️ A friendly language for building type-safe, scalable systems!
- [gluon_fmt](https://github.com/gluon-lang/gluon) - Code formatting for the gluon programming language.
- [gn](https://gn.googlesource.com/gn/) - gn build system.
- [gofmt](https://pkg.go.dev/cmd/gofmt) - Formats go programs.
- [gofumpt](https://github.com/mvdan/gofumpt) - Enforce a stricter format than gofmt, while being backwards compatible. That is, gofumpt is happy with a subset of the formats that gofmt is happy with.
- [goimports](https://pkg.go.dev/golang.org/x/tools/cmd/goimports) - Updates your Go import lines, adding missing ones and removing unreferenced ones.
- [goimports-reviser](https://github.com/incu6us/goimports-reviser) - Right imports sorting & code formatting tool (goimports alternative).
- [gojq](https://github.com/itchyny/gojq) - Pure Go implementation of jq.
- [golangci-lint](https://golangci-lint.run/usage/configuration/#fmt) - Fast linters runner for Go (with formatter).
- [golines](https://github.com/segmentio/golines) - A golang formatter that fixes long lines.
- [google-java-format](https://github.com/google/google-java-format) - Reformats Java source code according to Google Java Style.
- [grain_format](https://grain-lang.org/docs/tooling/grain_cli#grain-format) - Code formatter for the grain programming language.
- [hcl](https://github.com/hashicorp/hcl) - A formatter for HCL files.
- [hindent](https://github.com/mihaimaruseac/hindent) - Haskell pretty printer.
- [hledger-fmt](https://github.com/mondeja/hledger-fmt) - An opinionated hledger's journal files formatter.
- [html_beautify](https://github.com/beautifier/js-beautify) - Beautifier for html.
- [htmlbeautifier](https://github.com/threedaymonk/htmlbeautifier) - A normaliser/beautifier for HTML that also understands embedded Ruby. Ideal for tidying up Rails templates.
- [hurlfmt](https://hurl.dev/) - Formats hurl files.
- [imba_fmt](https://imba.io/) - Code formatter for the Imba programming language.
- [indent](https://www.gnu.org/software/indent/) - GNU Indent.
- [injected](doc/advanced_topics.md#injected-language-formatting-code-blocks) - Format treesitter injected languages.
- [inko](https://inko-lang.org/) - A language for building concurrent software with confidence
- [isort](https://github.com/PyCQA/isort) - Python utility / library to sort imports alphabetically and automatically separate them into sections and by type.
- [janet-format](https://github.com/janet-lang/spork) - A formatter for Janet code.
- [joker](https://github.com/candid82/joker) - Small Clojure interpreter, linter and formatter.
- [jq](https://github.com/stedolan/jq) - Command-line JSON processor.
- [js_beautify](https://github.com/beautifier/js-beautify) - Beautifier for javascript.
- [jsonnetfmt](https://github.com/google/go-jsonnet/tree/master/cmd/jsonnetfmt) - jsonnetfmt is a command line tool to format jsonnet files.
- [just](https://github.com/casey/just) - Format Justfile.
- [kcl](https://www.kcl-lang.io/docs/tools/cli/kcl/fmt) - The KCL Format tool modifies the files according to the KCL code style.
- [kdlfmt](https://github.com/hougesen/kdlfmt) - A formatter for kdl documents.
- [keep-sorted](https://github.com/google/keep-sorted) - keep-sorted is a language-agnostic formatter that sorts lines between two markers in a larger file.
- [ktfmt](https://github.com/facebook/ktfmt) - Reformats Kotlin source code to comply with the common community standard conventions.
- [ktlint](https://ktlint.github.io/) - An anti-bikeshedding Kotlin linter with built-in formatter.
- [kulala-fmt](https://github.com/mistweaverco/kulala-fmt) - An opinionated .http and .rest files linter and formatter.
- [latexindent](https://github.com/cmhughes/latexindent.pl) - A perl script for formatting LaTeX files that is generally included in major TeX distributions.
- [leptosfmt](https://github.com/bram209/leptosfmt) - A formatter for the Leptos view! macro.
- [liquidsoap-prettier](https://github.com/savonet/liquidsoap-prettier) - A binary to format Liquidsoap scripts
- [llf](https://repo.or.cz/llf.git) - A LaTeX reformatter / beautifier.
- [lua-format](https://github.com/Koihik/LuaFormatter) - Code formatter for Lua.
- [mago_format](https://github.com/carthage-software/mago) - Mago is a toolchain for PHP that aims to provide a set of tools to help developers write better code.
- [mago_lint](https://github.com/carthage-software/mago) - Mago is a toolchain for PHP that aims to provide a set of tools to help developers write better code.
- [markdown-toc](https://github.com/jonschlinkert/markdown-toc) - API and CLI for generating a markdown TOC (table of contents) for a README or any markdown files.
- [markdownfmt](https://github.com/shurcooL/markdownfmt) - Like gofmt, but for Markdown.
- [markdownlint](https://github.com/DavidAnson/markdownlint) - A Node.js style checker and lint tool for Markdown/CommonMark files.
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) - A fast, flexible, configuration-based command-line interface for linting Markdown/CommonMark files with the markdownlint library.
- [mdformat](https://github.com/executablebooks/mdformat) - An opinionated Markdown formatter.
- [mdsf](https://github.com/hougesen/mdsf) - Format markdown code blocks using your favorite code formatters.
- [mdslw](https://github.com/razziel89/mdslw) - Prepare your markdown for easy diff'ing by adding line breaks after every sentence.
- [mix](https://hexdocs.pm/mix/main/Mix.Tasks.Format.html) - Format Elixir files using the mix format command.
- [mojo_format](https://docs.modular.com/mojo/cli/format) - Official Formatter for The Mojo Programming Language
- [nginxfmt](https://github.com/slomkowski/nginx-config-formatter) - nginx config file formatter/beautifier written in Python with no additional dependencies.
- [nickel](https://nickel-lang.org/) - Code formatter for the Nickel programming language.
- [nimpretty](https://github.com/nim-lang/nim) - nimpretty is a Nim source code beautifier that follows the official style guide.
- [nixfmt](https://github.com/NixOS/nixfmt) - The official (but not yet stable) formatter for Nix code.
- [nixpkgs_fmt](https://github.com/nix-community/nixpkgs-fmt) - nixpkgs-fmt is a Nix code formatter for nixpkgs.
- [nomad_fmt](https://developer.hashicorp.com/nomad/docs/commands/fmt) - The fmt commands check the syntax and rewrites Nomad configuration and jobspec files to canonical format.
- [nph](https://github.com/arnetheduck/nph) - An opinionated code formatter for Nim.
- [npm-groovy-lint](https://github.com/nvuillam/npm-groovy-lint) - Lint, format and auto-fix your Groovy / Jenkinsfile / Gradle files using command line.
- [nufmt](https://github.com/nushell/nufmt) - The nushell formatter.
- [ocamlformat](https://github.com/ocaml-ppx/ocamlformat) - Auto-formatter for OCaml code.
- [ocp-indent](https://github.com/OCamlPro/ocp-indent) - Automatic indentation of OCaml source files.
- [odinfmt](https://github.com/DanielGavin/ols) - Auto-formatter for the Odin programming language.
- [opa_fmt](https://www.openpolicyagent.org/docs/latest/cli/#opa-fmt) - Format Rego files using `opa fmt` command.
- [ormolu](https://hackage.haskell.org/package/ormolu) - A formatter for Haskell source code.
- [packer_fmt](https://developer.hashicorp.com/packer/docs/commands/fmt) - The packer fmt Packer command is used to format HCL2 configuration files to a canonical format and style.
- [pangu](https://github.com/vinta/pangu.py) - Insert whitespace between CJK and half-width characters.
- [perlimports](https://github.com/perl-ide/App-perlimports) - Make implicit Perl imports explicit.
- [perltidy](https://github.com/perltidy/perltidy) - Perl::Tidy, a source code formatter for Perl.
- [pg_format](https://github.com/darold/pgFormatter) - PostgreSQL SQL syntax beautifier.
- [php_cs_fixer](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer) - The PHP Coding Standards Fixer.
- [phpcbf](https://phpqa.io/projects/phpcbf.html) - PHP Code Beautifier and Fixer fixes violations of a defined coding standard.
- [phpinsights](https://github.com/nunomaduro/phpinsights) - The perfect starting point to analyze the code quality of your PHP projects.
- [pint](https://github.com/laravel/pint) - Laravel Pint is an opinionated PHP code style fixer for minimalists.
- [prettier](https://github.com/prettier/prettier) - Prettier is an opinionated code formatter. It enforces a consistent style by parsing your code and re-printing it with its own rules that take the maximum line length into account, wrapping code when necessary.
- [prettierd](https://github.com/fsouza/prettierd) - prettier, as a daemon, for ludicrous formatting speed.
- [pretty-php](https://github.com/lkrms/pretty-php) - The opinionated PHP code formatter.
- [prettypst](https://github.com/antonWetzel/prettypst) - Formatter for Typst.
- [puppet-lint](https://github.com/puppetlabs/puppet-lint) - Check that your Puppet manifests conform to the style guide.
- [purs-tidy](https://github.com/natefaubion/purescript-tidy) - A syntax tidy-upper for PureScript.
- [pycln](https://github.com/hadialqattan/pycln) - A Python formatter for finding and removing unused import statements.
- [pyink](https://github.com/google/pyink) - A Python formatter, forked from Black with a few different formatting behaviors.
- [pyproject-fmt](https://github.com/tox-dev/toml-fmt/tree/main/pyproject-fmt) - Apply a consistent format to your pyproject.toml file with comment support.
- [python-ly](https://github.com/frescobaldi/python-ly) - A Python package and commandline tool to manipulate LilyPond files.
- [pyupgrade](https://github.com/asottile/pyupgrade) - A tool to automatically upgrade syntax for newer versions of Python.
- [reformat-gherkin](https://github.com/ducminh-phan/reformat-gherkin) - Formatter for Gherkin language.
- [reorder-python-imports](https://github.com/asottile/reorder-python-imports) - Rewrites source to reorder python imports
- [rescript-format](https://rescript-lang.org/) - The built-in ReScript formatter.
- [roc](https://github.com/roc-lang/roc) - A fast, friendly, functional language.
- [rstfmt](https://github.com/dzhu/rstfmt) - A formatter for reStructuredText.
- [rubocop](https://github.com/rubocop/rubocop) - Ruby static code analyzer and formatter, based on the community Ruby style guide.
- [rubyfmt](https://github.com/fables-tales/rubyfmt) - Ruby Autoformatter! (Written in Rust)
- [ruff_fix](https://docs.astral.sh/ruff/) - An extremely fast Python linter, written in Rust. Fix lint errors.
- [ruff_format](https://docs.astral.sh/ruff/) - An extremely fast Python linter, written in Rust. Formatter subcommand.
- [ruff_organize_imports](https://docs.astral.sh/ruff/) - An extremely fast Python linter, written in Rust. Organize imports.
- [rufo](https://github.com/ruby-formatter/rufo) - Rufo is an opinionated ruby formatter.
- [runic](https://github.com/fredrikekre/Runic.jl) - Julia code formatter.
- [rustfmt](https://github.com/rust-lang/rustfmt) - A tool for formatting rust code according to style guidelines.
- [rustywind](https://github.com/avencera/rustywind) - A tool for formatting Tailwind CSS classes.
- [scalafmt](https://github.com/scalameta/scalafmt) - Code formatter for Scala.
- [shellcheck](https://github.com/koalaman/shellcheck) - A static analysis tool for shell scripts.
- [shellharden](https://github.com/anordal/shellharden) - The corrective bash syntax highlighter.
- [shfmt](https://github.com/mvdan/sh) - A shell parser, formatter, and interpreter with `bash` support.
- [sleek](https://github.com/nrempel/sleek) - Sleek is a CLI tool for formatting SQL.
- [smlfmt](https://github.com/shwestrick/smlfmt) - A custom parser and code formatter for Standard ML.
- [snakefmt](https://github.com/snakemake/snakefmt) - a formatting tool for Snakemake files following the design of Black.
- [sql_formatter](https://github.com/sql-formatter-org/sql-formatter) - A whitespace formatter for different query languages.
- [sqlfluff](https://github.com/sqlfluff/sqlfluff) - A modular SQL linter and auto-formatter with support for multiple dialects and templated code.
- [sqlfmt](https://docs.sqlfmt.com) - sqlfmt formats your dbt SQL files so you don't have to. It is similar in nature to Black, gofmt, and rustfmt (but for SQL)
- [sqruff](https://github.com/quarylabs/sqruff) - sqruff is a SQL linter and formatter written in Rust.
- [squeeze_blanks](https://www.gnu.org/software/coreutils/manual/html_node/cat-invocation.html#cat-invocation) - Squeeze repeated blank lines into a single blank line via `cat -s`.
- [standard-clj](https://github.com/oakmac/standard-clojure-style-js) - A JavaScript library to format Clojure code according to Standard Clojure Style.
- [standardjs](https://standardjs.com) - JavaScript Standard style guide, linter, and formatter.
- [standardrb](https://github.com/standardrb/standard) - Ruby's bikeshed-proof linter and formatter.
- [stylelint](https://github.com/stylelint/stylelint) - A mighty CSS linter that helps you avoid errors and enforce conventions.
- [styler](https://github.com/devOpifex/r.nvim) - R formatter and linter.
- [stylish-haskell](https://github.com/haskell/stylish-haskell) - Haskell code prettifier.
- [stylua](https://github.com/JohnnyMorganz/StyLua) - An opinionated code formatter for Lua.
- [superhtml](https://github.com/kristoff-it/superhtml) - HTML Language Server and Templating Language Library.
- [swift](https://github.com/swiftlang/swift-format) - Official Swift formatter. Requires Swift 6.0 or later.
- [swift_format](https://github.com/swiftlang/swift-format) - Official Swift formatter. For Swift 6.0 or later prefer setting the `swift` formatter instead.
- [swiftformat](https://github.com/nicklockwood/SwiftFormat) - SwiftFormat is a code library and command-line tool for reformatting `swift` code on macOS or Linux.
- [swiftlint](https://github.com/realm/SwiftLint) - A tool to enforce Swift style and conventions.
- [syntax_tree](https://github.com/ruby-syntax-tree/syntax_tree) - Syntax Tree is a suite of tools built on top of the internal CRuby parser.
- [taplo](https://github.com/tamasfe/taplo) - A TOML toolkit written in Rust.
- [templ](https://templ.guide/developer-tools/cli/#formatting-templ-files) - Formats templ template files.
- [terraform_fmt](https://www.terraform.io/docs/cli/commands/fmt.html) - The terraform-fmt command rewrites `terraform` configuration files to a canonical format and style.
- [terragrunt_hclfmt](https://terragrunt.gruntwork.io/docs/reference/cli-options/#hclfmt) - Format hcl files into a canonical format.
- [tex-fmt](https://github.com/WGUNDERWOOD/tex-fmt) - An extremely fast LaTeX formatter written in Rust.
- [tlint](https://github.com/tighten/tlint) - Tighten linter for Laravel conventions with support for auto-formatting.
- [tofu_fmt](https://opentofu.org/docs/cli/commands/fmt/) - The tofu-fmt command rewrites OpenTofu configuration files to a canonical format and style.
- [tombi](https://github.com/tombi-toml/tombi) - TOML Formatter / Linter.
- [treefmt](https://github.com/numtide/treefmt) - one CLI to format your repo.
- [trim_newlines](https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/trim_newlines.lua) - Trim empty lines at the end of the file.
- [trim_whitespace](https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/trim_whitespace.lua) - Trim trailing whitespace.
- [twig-cs-fixer](https://github.com/VincentLanglet/Twig-CS-Fixer) - Automatically fix Twig Coding Standards issues
- [typespec](https://github.com/microsoft/typespec) - TypeSpec compiler and CLI.
- [typos](https://github.com/crate-ci/typos) - Source code spell checker
- [typstyle](https://github.com/Enter-tainer/typstyle) - Beautiful and reliable typst code formatter.
- [ufmt](https://github.com/omnilib/ufmt) - Safe, atomic formatting with black and µsort.
- [uncrustify](https://github.com/uncrustify/uncrustify) - A source code beautifier for C, C++, C#, ObjectiveC, D, Java, Pawn and Vala.
- [usort](https://github.com/facebook/usort) - Safe, minimal import sorting for Python projects.
- [v](https://vlang.io) - V language formatter.
- [verible](https://github.com/chipsalliance/verible/blob/master/verilog/tools/formatter/README.md) - The SystemVerilog formatter.
- [vsg](https://github.com/jeremiah-c-leary/vhdl-style-guide) - Style guide enforcement for VHDL.
- [xmlformatter](https://github.com/pamoller/xmlformatter) - xmlformatter is an Open Source Python package, which provides formatting of XML documents.
- [xmllint](http://xmlsoft.org/xmllint.html) - Despite the name, xmllint can be used to format XML files as well as lint them.
- [xmlstarlet](http://xmlstar.sourceforge.net/) - XMLStarlet is a command-line XML toolkit that can be used to format XML files.
- [yamlfix](https://github.com/lyz-code/yamlfix) - A configurable YAML formatter that keeps comments.
- [yamlfmt](https://github.com/google/yamlfmt) - yamlfmt is an extensible command line tool or library to format yaml files.
- [yapf](https://github.com/google/yapf) - Yet Another Python Formatter.
- [yew-fmt](https://github.com/schvv31n/yew-fmt) - Code formatter for the Yew framework.
- [yq](https://github.com/mikefarah/yq) - YAML/JSON processor
- [zigfmt](https://github.com/ziglang/zig) - Reformat Zig source into canonical form.
- [ziggy](https://github.com/kristoff-it/ziggy) - A data serialization language for expressing clear API messages, config files, etc.
- [ziggy_schema](https://github.com/kristoff-it/ziggy) - A data serialization language for expressing clear API messages, config files, etc.
- [zprint](https://github.com/kkinnear/zprint) - Formatter for Clojure and EDN.
<!-- /FORMATTERS -->

</details>

## Customizing formatters

You can override/add to the default values of formatters

```lua
require("conform").setup({
  formatters = {
    yamlfix = {
      -- Change where to find the command
      command = "local/path/yamlfix",
      -- Adds environment args to the yamlfix formatter
      env = {
        YAMLFIX_SEQUENCE_STYLE = "block_style",
      },
    },
  },
})

-- These can also be set directly
require("conform").formatters.yamlfix = {
  env = {
    YAMLFIX_SEQUENCE_STYLE = "block_style",
  },
}

-- This can also be a function that returns the config,
-- which can be useful if you're doing lazy loading
require("conform").formatters.yamlfix = function(bufnr)
  return {
    command = require("conform.util").find_executable({
      "local/path/yamlfix",
    }, "yamlfix"),
  }
end
```

In addition to being able to override any of the original properties on the formatter, there is another property for easily adding additional arguments to the format command

```lua
require("conform").formatters.shfmt = {
  prepend_args = { "-i", "2" },
  -- The base args are { "-filename", "$FILENAME" } so the final args will be
  -- { "-i", "2", "-filename", "$FILENAME" }
}
-- prepend_args can be a function, just like args
require("conform").formatters.shfmt = {
  prepend_args = function(self, ctx)
    return { "-i", "2" }
  end,
}
```

If you want to overwrite the entire formatter definition and _not_ merge with the default values, pass `inherit = false`. This is also the default behavior if there is no built-in formatter with the given name, which can be used to add your own custom formatters.

```lua
require("conform").formatters.shfmt = {
  inherit = false,
  command = "shfmt",
  args = { "-i", "2", "-filename", "$FILENAME" },
}
```

### Magic strings

The following magic strings are available in `args` and `range_args`. They will be dynamically replaced at runtime with the relevant value.

- `$FILENAME` - absolute path to the file
- `$DIRNAME` - absolute path to the directory that contains the file
- `$RELATIVE_FILEPATH` - relative path to the file
- `$EXTENSION` - the file extension, e.g. `.py`

## Recipes

<!-- RECIPES -->

- [Format command](doc/recipes.md#format-command)
- [Autoformat with extra features](doc/recipes.md#autoformat-with-extra-features)
- [Command to toggle format-on-save](doc/recipes.md#command-to-toggle-format-on-save)
- [Lazy loading with lazy.nvim](doc/recipes.md#lazy-loading-with-lazynvim)
- [Leave visual mode after range format](doc/recipes.md#leave-visual-mode-after-range-format)
- [Run the first available formatter followed by more formatters](doc/recipes.md#run-the-first-available-formatter-followed-by-more-formatters)

<!-- /RECIPES -->

## Debugging

<!-- DEBUGGING -->

- [Background](doc/debugging.md#background)
- [Tools](doc/debugging.md#tools)
- [Testing the formatter](doc/debugging.md#testing-the-formatter)
- [Testing vim.system](doc/debugging.md#testing-vimsystem)

<!-- /DEBUGGING -->

## Advanced topics

<!-- ADVANCED -->

- [Minimal format diffs](doc/advanced_topics.md#minimal-format-diffs)
- [Range formatting](doc/advanced_topics.md#range-formatting)
- [Injected language formatting (code blocks)](doc/advanced_topics.md#injected-language-formatting-code-blocks)

<!-- /ADVANCED -->

## Options

A complete list of all configuration options

<!-- OPTIONS -->

```lua
require("conform").setup({
  -- Map of filetype to formatters
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    go = { "goimports", "gofmt" },
    -- You can also customize some of the format options for the filetype
    rust = { "rustfmt", lsp_format = "fallback" },
    -- You can use a function here to determine the formatters dynamically
    python = function(bufnr)
      if require("conform").get_formatter_info("ruff_format", bufnr).available then
        return { "ruff_format" }
      else
        return { "isort", "black" }
      end
    end,
    -- Use the "*" filetype to run formatters on all filetypes.
    ["*"] = { "codespell" },
    -- Use the "_" filetype to run formatters on filetypes that don't
    -- have other formatters configured.
    ["_"] = { "trim_whitespace" },
  },
  -- Set this to change the default values when calling conform.format()
  -- This will also affect the default values for format_on_save/format_after_save
  default_format_opts = {
    lsp_format = "fallback",
  },
  -- If this is set, Conform will run the formatter on save.
  -- It will pass the table to conform.format().
  -- This can also be a function that returns the table.
  format_on_save = {
    -- I recommend these options. See :help conform.format for details.
    lsp_format = "fallback",
    timeout_ms = 500,
  },
  -- If this is set, Conform will run the formatter asynchronously after save.
  -- It will pass the table to conform.format().
  -- This can also be a function that returns the table.
  format_after_save = {
    lsp_format = "fallback",
  },
  -- Set the log level. Use `:ConformInfo` to see the location of the log file.
  log_level = vim.log.levels.ERROR,
  -- Conform will notify you when a formatter errors
  notify_on_error = true,
  -- Conform will notify you when no formatters are available for the buffer
  notify_no_formatters = true,
  -- Custom formatters and overrides for built-in formatters
  formatters = {
    my_formatter = {
      -- This can be a string or a function that returns a string.
      -- When defining a new formatter, this is the only field that is required
      command = "my_cmd",
      -- A list of strings, or a function that returns a list of strings
      -- Return a single string instead of a list to run the command in a shell
      args = { "--stdin-from-filename", "$FILENAME" },
      -- If the formatter supports range formatting, create the range arguments here
      range_args = function(self, ctx)
        return { "--line-start", ctx.range.start[1], "--line-end", ctx.range["end"][1] }
      end,
      -- Send file contents to stdin, read new contents from stdout (default true)
      -- When false, will create a temp file (will appear in "$FILENAME" args). The temp
      -- file is assumed to be modified in-place by the format command.
      stdin = true,
      -- A function that calculates the directory to run the command in
      cwd = require("conform.util").root_file({ ".editorconfig", "package.json" }),
      -- When cwd is not found, don't run the formatter (default false)
      require_cwd = true,
      -- When stdin=false, use this template to generate the temporary file that gets formatted
      tmpfile_format = ".conform.$RANDOM.$FILENAME",
      -- When returns false, the formatter will not be used
      condition = function(self, ctx)
        return vim.fs.basename(ctx.filename) ~= "README.md"
      end,
      -- Exit codes that indicate success (default { 0 })
      exit_codes = { 0, 1 },
      -- Environment variables. This can also be a function that returns a table.
      env = {
        VAR = "value",
      },
      -- Set to false to disable merging the config with the base definition
      inherit = true,
      -- When inherit = true, add these additional arguments to the beginning of the command.
      -- This can also be a function, like args
      prepend_args = { "--use-tabs" },
      -- When inherit = true, add these additional arguments to the end of the command.
      -- This can also be a function, like args
      append_args = { "--trailing-comma" },
    },
    -- These can also be a function that returns the formatter
    other_formatter = function(bufnr)
      return {
        command = "my_cmd",
      }
    end,
  },
})

-- You can set formatters_by_ft and formatters directly
require("conform").formatters_by_ft.lua = { "stylua" }
require("conform").formatters.my_formatter = {
  command = "my_cmd",
}
```

<!-- /OPTIONS -->

## Formatter options

<!-- FORMATTER_OPTIONS -->

- [injected](doc/formatter_options.md#injected)
- [prettier](doc/formatter_options.md#prettier)
- [rustfmt](doc/formatter_options.md#rustfmt)
- [yew-fmt](doc/formatter_options.md#yew-fmt)

<!-- /FORMATTER_OPTIONS -->

## API

<!-- API -->

### setup(opts)

`setup(opts)`

| Param                 | Type                                                                                                             | Desc                                                                                                                                                                                                                                                                                |
| --------------------- | ---------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| opts                  | `nil\|conform.setupOpts`                                                                                         |                                                                                                                                                                                                                                                                                     |
| >formatters_by_ft     | `nil\|table<string, conform.FiletypeFormatter>`                                                                  | Map of filetype to formatters                                                                                                                                                                                                                                                       |
| >format_on_save       | `nil\|conform.FormatOpts\|fun(bufnr: integer): nil\|conform.FormatOpts`                                          | If this is set, Conform will run the formatter on save. It will pass the table to conform.format(). This can also be a function that returns the table.                                                                                                                             |
| >default_format_opts  | `nil\|conform.DefaultFormatOpts`                                                                                 | The default options to use when calling conform.format()                                                                                                                                                                                                                            |
| >>timeout_ms          | `nil\|integer`                                                                                                   | Time in milliseconds to block for formatting. Defaults to 1000. No effect if async = true.                                                                                                                                                                                          |
| >>lsp_format          | `nil\|conform.LspFormatOpts`                                                                                     | Configure if and when LSP should be used for formatting. Defaults to "never".                                                                                                                                                                                                       |
|                       | `"never"`                                                                                                        | never use the LSP for formatting (default)                                                                                                                                                                                                                                          |
|                       | `"fallback"`                                                                                                     | LSP formatting is used when no other formatters are available                                                                                                                                                                                                                       |
|                       | `"prefer"`                                                                                                       | use only LSP formatting when available                                                                                                                                                                                                                                              |
|                       | `"first"`                                                                                                        | LSP formatting is used when available and then other formatters                                                                                                                                                                                                                     |
|                       | `"last"`                                                                                                         | other formatters are used then LSP formatting when available                                                                                                                                                                                                                        |
| >>quiet               | `nil\|boolean`                                                                                                   | Don't show any notifications for warnings or failures. Defaults to false.                                                                                                                                                                                                           |
| >>stop_after_first    | `nil\|boolean`                                                                                                   | Only run the first available formatter in the list. Defaults to false.                                                                                                                                                                                                              |
| >format_after_save    | `nil\|conform.FormatOpts\|fun(bufnr: integer): nil\|conform.FormatOpts`                                          | , nil|fun(err: nil|string, did_edit: nil|boolean) If this is set, Conform will run the formatter asynchronously after save. It will pass the table to conform.format(). This can also be a function that returns the table (and an optional callback that is run after formatting). |
| >log_level            | `nil\|integer`                                                                                                   | Set the log level (e.g. `vim.log.levels.DEBUG`). Use `:ConformInfo` to see the location of the log file.                                                                                                                                                                            |
| >notify_on_error      | `nil\|boolean`                                                                                                   | Conform will notify you when a formatter errors (default true).                                                                                                                                                                                                                     |
| >notify_no_formatters | `nil\|boolean`                                                                                                   | Conform will notify you when no formatters are available for the buffer (default true).                                                                                                                                                                                             |
| >formatters           | `nil\|table<string, conform.FormatterConfigOverride\|fun(bufnr: integer): nil\|conform.FormatterConfigOverride>` | Custom formatters and overrides for built-in formatters.                                                                                                                                                                                                                            |

### format(opts, callback)

`format(opts, callback): boolean` \
Format a buffer

| Param               | Type                                                 | Desc                                                                                                                                                 |
| ------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| opts                | `nil\|conform.FormatOpts`                            |                                                                                                                                                      |
| >timeout_ms         | `nil\|integer`                                       | Time in milliseconds to block for formatting. Defaults to 1000. No effect if async = true.                                                           |
| >bufnr              | `nil\|integer`                                       | Format this buffer (default 0)                                                                                                                       |
| >async              | `nil\|boolean`                                       | If true the method won't block. Defaults to false. If the buffer is modified before the formatter completes, the formatting will be discarded.       |
| >dry_run            | `nil\|boolean`                                       | If true don't apply formatting changes to the buffer                                                                                                 |
| >undojoin           | `nil\|boolean`                                       | Use undojoin to merge formatting changes with previous edit (default false)                                                                          |
| >formatters         | `nil\|string[]`                                      | List of formatters to run. Defaults to all formatters for the buffer filetype.                                                                       |
| >lsp_format         | `nil\|conform.LspFormatOpts`                         | Configure if and when LSP should be used for formatting. Defaults to "never".                                                                        |
|                     | `"never"`                                            | never use the LSP for formatting (default)                                                                                                           |
|                     | `"fallback"`                                         | LSP formatting is used when no other formatters are available                                                                                        |
|                     | `"prefer"`                                           | use only LSP formatting when available                                                                                                               |
|                     | `"first"`                                            | LSP formatting is used when available and then other formatters                                                                                      |
|                     | `"last"`                                             | other formatters are used then LSP formatting when available                                                                                         |
| >stop_after_first   | `nil\|boolean`                                       | Only run the first available formatter in the list. Defaults to false.                                                                               |
| >quiet              | `nil\|boolean`                                       | Don't show any notifications for warnings or failures. Defaults to false.                                                                            |
| >range              | `nil\|conform.Range`                                 | Range to format. Table must contain `start` and `end` keys with {row, col} tuples using (1,0) indexing. Defaults to current selection in visual mode |
| >>start             | `integer[]`                                          |                                                                                                                                                      |
| >>end               | `integer[]`                                          |                                                                                                                                                      |
| >id                 | `nil\|integer`                                       | Passed to vim.lsp.buf.format when using LSP formatting                                                                                               |
| >name               | `nil\|string`                                        | Passed to vim.lsp.buf.format when using LSP formatting                                                                                               |
| >filter             | `nil\|fun(client: table): boolean`                   | Passed to vim.lsp.buf.format when using LSP formatting                                                                                               |
| >formatting_options | `nil\|table`                                         | Passed to vim.lsp.buf.format when using LSP formatting                                                                                               |
| callback            | `nil\|fun(err: nil\|string, did_edit: nil\|boolean)` | Called once formatting has completed                                                                                                                 |

Returns:

| Type    | Desc                                  |
| ------- | ------------------------------------- |
| boolean | True if any formatters were attempted |

**Examples:**
```lua
-- Synchronously format the current buffer
conform.format({ lsp_format = "fallback" })
-- Asynchronously format the current buffer; will not block the UI
conform.format({ async = true }, function(err, did_edit)
  -- called after formatting
end
-- Format the current buffer with a specific formatter
conform.format({ formatters = { "ruff_fix" } })
```

### list_formatters(bufnr)

`list_formatters(bufnr): conform.FormatterInfo[]` \
Retrieve the available formatters for a buffer

| Param | Type           | Desc |
| ----- | -------------- | ---- |
| bufnr | `nil\|integer` |      |

### list_formatters_to_run(bufnr)

`list_formatters_to_run(bufnr): conform.FormatterInfo[], boolean` \
Get the exact formatters that will be run for a buffer.

| Param | Type           | Desc |
| ----- | -------------- | ---- |
| bufnr | `nil\|integer` |      |

Returns:

| Type                    | Desc                       |
| ----------------------- | -------------------------- |
| conform.FormatterInfo[] |                            |
| boolean                 | lsp Will use LSP formatter |

**Note:**
<pre>
This accounts for stop_after_first, lsp fallback logic, etc.
</pre>

### list_all_formatters()

`list_all_formatters(): conform.FormatterInfo[]` \
List information about all filetype-configured formatters


### get_formatter_info(formatter, bufnr)

`get_formatter_info(formatter, bufnr): conform.FormatterInfo` \
Get information about a formatter (including availability)

| Param     | Type           | Desc                      |
| --------- | -------------- | ------------------------- |
| formatter | `string`       | The name of the formatter |
| bufnr     | `nil\|integer` |                           |
<!-- /API -->

## FAQ

**Q:** Instead of passing `lsp_format = "..."`, could you just define a `lsp` formatter? \
**A:** No. [#61](https://github.com/stevearc/conform.nvim/issues/61)

**Q:** Is it possible to define a custom formatter that runs a lua function? \
**A:** Yes, but with some very strict constraints. [#653](https://github.com/stevearc/conform.nvim/issues/653)

**Q:** Can I run a command like `:EslintFixAll` or a LSP code action as a formatter? \
**A:** No. [#502](https://github.com/stevearc/conform.nvim/issues/502), [#466](https://github.com/stevearc/conform.nvim/issues/466), [#222](https://github.com/stevearc/conform.nvim/issues/222)

## Acknowledgements

Thanks to

- [nvim-lint](https://github.com/mfussenegger/nvim-lint) for providing inspiration for the config and API. It's an excellent plugin that balances power and simplicity.
- [null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim) for formatter configurations and being my formatter/linter of choice for a long time.
