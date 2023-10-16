# Changelog

## [4.0.0](https://github.com/stevearc/conform.nvim/compare/v3.10.0...v4.0.0) (2023-10-16)


### ⚠ BREAKING CHANGES

* merge configs in conform.formatters with defaults ([#140](https://github.com/stevearc/conform.nvim/issues/140))

### Features

* add blade-formatter ([#136](https://github.com/stevearc/conform.nvim/issues/136)) ([f90b222](https://github.com/stevearc/conform.nvim/commit/f90b2229c481252c43a71a004972b473952c1c3c))
* add blue formatter ([#142](https://github.com/stevearc/conform.nvim/issues/142)) ([a97ddff](https://github.com/stevearc/conform.nvim/commit/a97ddfff2d701245ad49daf24ef436a50ee72a50))
* Add config for laravel/pint ([#144](https://github.com/stevearc/conform.nvim/issues/144)) ([43414c8](https://github.com/stevearc/conform.nvim/commit/43414c8ebd22921f44806fb9612a2f4f376419af))
* add goimports-reviser ([#143](https://github.com/stevearc/conform.nvim/issues/143)) ([3fcebb0](https://github.com/stevearc/conform.nvim/commit/3fcebb0001e6d5b943dbb36fe5c035e3ef8c3509))
* add ktlint ([#137](https://github.com/stevearc/conform.nvim/issues/137)) ([8b02f47](https://github.com/stevearc/conform.nvim/commit/8b02f478fefe93f76a7f57c983418744287f4c69))
* add rufo support ([#132](https://github.com/stevearc/conform.nvim/issues/132)) ([aca5d30](https://github.com/stevearc/conform.nvim/commit/aca5d307232a22600bd0ab57571a8b6e2dc9a12c))
* merge configs in conform.formatters with defaults ([#140](https://github.com/stevearc/conform.nvim/issues/140)) ([7027ebb](https://github.com/stevearc/conform.nvim/commit/7027ebbd772e2d3593f7dd566dea06d2d20622ee))
* support for rubyfmt ([#139](https://github.com/stevearc/conform.nvim/issues/139)) ([ae33777](https://github.com/stevearc/conform.nvim/commit/ae337775e46804a8347ea7c3da92be5587e5850e))


### Bug Fixes

* prevent format-after-save autocmd from running on invalid buffers ([80f2f70](https://github.com/stevearc/conform.nvim/commit/80f2f70740431b07d725cc66f63abbfd66aaae6d))
* prevent format-on-save autocmd from running on invalid buffers ([#128](https://github.com/stevearc/conform.nvim/issues/128)) ([69ee0bf](https://github.com/stevearc/conform.nvim/commit/69ee0bfde439e30344ae57de6227cb3a035dd0bb))
* **shellcheck:** support filenames with spaces ([#135](https://github.com/stevearc/conform.nvim/issues/135)) ([64a8956](https://github.com/stevearc/conform.nvim/commit/64a89568925c3f62b7ecdcf60b612001d2749eb1))

## [3.10.0](https://github.com/stevearc/conform.nvim/compare/v3.9.0...v3.10.0) (2023-10-09)


### Features

* add easy-coding-standard ([#121](https://github.com/stevearc/conform.nvim/issues/121)) ([e758196](https://github.com/stevearc/conform.nvim/commit/e75819642c36810a55a7235b6b5e16a5ce896ed3))
* add fixjson ([#126](https://github.com/stevearc/conform.nvim/issues/126)) ([280360e](https://github.com/stevearc/conform.nvim/commit/280360eb019fe52433a68b7918790c9187076865))
* add justfile formatter ([#114](https://github.com/stevearc/conform.nvim/issues/114)) ([4c91b52](https://github.com/stevearc/conform.nvim/commit/4c91b5270a6f741850de2eef3a804ff1dc6ec3ee))
* errors do not stop formatting early ([a94f686](https://github.com/stevearc/conform.nvim/commit/a94f686986631d5b97bd75b3877813c39de55c47))
* expose configuration options for injected formatter ([#118](https://github.com/stevearc/conform.nvim/issues/118)) ([ba1ca20](https://github.com/stevearc/conform.nvim/commit/ba1ca20bb5f89a8bdd94b268411263275550843a))


### Bug Fixes

* **biome:** do not use stdin due to biome bug ([#120](https://github.com/stevearc/conform.nvim/issues/120)) ([e5ed063](https://github.com/stevearc/conform.nvim/commit/e5ed0635d9aa66c6c2f7eac3235e6a8eb2de0653))
* catch and fix more cases of bad-behaving LSP formatters ([#119](https://github.com/stevearc/conform.nvim/issues/119)) ([9bd1690](https://github.com/stevearc/conform.nvim/commit/9bd169029ac7fac5d0b3899a47556549d113a4c2))
* handle one failure mode with range formatting ([#123](https://github.com/stevearc/conform.nvim/issues/123)) ([b5a2da9](https://github.com/stevearc/conform.nvim/commit/b5a2da9410d56bd7bc229d0185ad427a966cac50))
* injected formatter handles markdown code blocks in blockquotes ([#117](https://github.com/stevearc/conform.nvim/issues/117)) ([0bffab5](https://github.com/stevearc/conform.nvim/commit/0bffab53672d62cbfe8fc450e78757982e656318))
* move justfile formatter to correct directory ([8217144](https://github.com/stevearc/conform.nvim/commit/8217144491e8aba3a24828a71ee768b007a2ec43))

## [3.9.0](https://github.com/stevearc/conform.nvim/compare/v3.8.0...v3.9.0) (2023-10-04)


### Features

* add phpcbf ([#103](https://github.com/stevearc/conform.nvim/issues/103)) ([db5af4b](https://github.com/stevearc/conform.nvim/commit/db5af4b04e5d61236a142ab78ec3f9416aab848c))
* gci formatter for Go ([#109](https://github.com/stevearc/conform.nvim/issues/109)) ([362e4ec](https://github.com/stevearc/conform.nvim/commit/362e4ec709d241e47d6093dd4b030125ce214cfa))


### Bug Fixes

* format on save autocmds ignore nonstandard buffers ([cb87cab](https://github.com/stevearc/conform.nvim/commit/cb87cab7a6baa6192bf13123c2a5af6fd059d62c))
* injected formatter silent failure on nvim nightly ([#100](https://github.com/stevearc/conform.nvim/issues/100)) ([0156beb](https://github.com/stevearc/conform.nvim/commit/0156beb8397169d7ec18d4f4ea8dd002ee9bcc96))
* phpcbf invalid stdin-path arguments ([#108](https://github.com/stevearc/conform.nvim/issues/108)) ([ce427b0](https://github.com/stevearc/conform.nvim/commit/ce427b03b9cc428ee7a64cb77487ed19efec202d))
* support for mix format ([#107](https://github.com/stevearc/conform.nvim/issues/107)) ([6836930](https://github.com/stevearc/conform.nvim/commit/6836930ed5a0ec6e8bb531116c62cc10f475c298))

## [3.8.0](https://github.com/stevearc/conform.nvim/compare/v3.7.2...v3.8.0) (2023-10-02)


### Features

* add 'google-java-format' formatter ([#99](https://github.com/stevearc/conform.nvim/issues/99)) ([e887736](https://github.com/stevearc/conform.nvim/commit/e8877369df244515af20e18bf1307632fc638d2a))
* add standardrb ([#91](https://github.com/stevearc/conform.nvim/issues/91)) ([37d0367](https://github.com/stevearc/conform.nvim/commit/37d036704a100ef6e6457be45b4dfc2f8e429572))
* metatable to make accessing formatters a bit easier ([#89](https://github.com/stevearc/conform.nvim/issues/89)) ([d8170c1](https://github.com/stevearc/conform.nvim/commit/d8170c14db0f3c90fa799db3bca29d3fb3c089c3))


### Bug Fixes

* alternations follow notification rules ([3f89275](https://github.com/stevearc/conform.nvim/commit/3f8927532bc8ce4fc4b5b75eab1bf8f1fc83f6b9))
* error handling for injected formatter ([f7b82fb](https://github.com/stevearc/conform.nvim/commit/f7b82fb395a4cd636a26ee879b5fd7690612e5a9))
* injected formatter doesn't have interruption errors ([af3d59d](https://github.com/stevearc/conform.nvim/commit/af3d59da20d2bc37933df409f8fc9e24ec15e066))
* injected formatter operates on input lines ([501319e](https://github.com/stevearc/conform.nvim/commit/501319eed2ff26f856ea91b5456bef1d00f77df7))

## [3.7.2](https://github.com/stevearc/conform.nvim/compare/v3.7.1...v3.7.2) (2023-09-29)


### Bug Fixes

* injected formatter hangs on empty file ([671186e](https://github.com/stevearc/conform.nvim/commit/671186e4b29e26ee9fc0f1df4e529134bc334666))
* injected formatter preserves indentation of code blocks ([470d419](https://github.com/stevearc/conform.nvim/commit/470d41988e83913df428c9e832c15b8bb84301ad))
* lsp format calls method from wrong util file ([df69e3e](https://github.com/stevearc/conform.nvim/commit/df69e3ee61e1a0cbb960c8466ace74c696cc7830))

## [3.7.1](https://github.com/stevearc/conform.nvim/compare/v3.7.0...v3.7.1) (2023-09-29)


### Bug Fixes

* format_after_save blocks on exit for lsp formatting ([0c52ee2](https://github.com/stevearc/conform.nvim/commit/0c52ee248245f40610a4957b6bc9515ce1fd9ab6))

## [3.7.0](https://github.com/stevearc/conform.nvim/compare/v3.6.0...v3.7.0) (2023-09-29)


### Features

* add 'JavaScript Standard Style' formatter ([#82](https://github.com/stevearc/conform.nvim/issues/82)) ([971fa7f](https://github.com/stevearc/conform.nvim/commit/971fa7f2e4005454ce141ca8ee0462a3c34d2922))
* add darker ([#80](https://github.com/stevearc/conform.nvim/issues/80)) ([e359687](https://github.com/stevearc/conform.nvim/commit/e359687e3684452ff45d7a5f1a59cd40b0bfa320))
* format injected languages ([#83](https://github.com/stevearc/conform.nvim/issues/83)) ([a5526fb](https://github.com/stevearc/conform.nvim/commit/a5526fb2ee963cf426ab6d6ba1f3eb82887b1c22))


### Bug Fixes

* format_after_save autocmd blocks nvim exit until complete ([388d6e2](https://github.com/stevearc/conform.nvim/commit/388d6e2440bccded26d5e67ce6a7039c1953ae70))
* only show "no formatters" warning if formatters passed in explicitly ([#85](https://github.com/stevearc/conform.nvim/issues/85)) ([45edf94](https://github.com/stevearc/conform.nvim/commit/45edf9462d06db0809d4a4a7afc6b7896b63fa35))

## [3.6.0](https://github.com/stevearc/conform.nvim/compare/v3.5.0...v3.6.0) (2023-09-27)


### Features

* add `markdown-toc` ([#75](https://github.com/stevearc/conform.nvim/issues/75)) ([de58b06](https://github.com/stevearc/conform.nvim/commit/de58b06d434047c6ecd5ec2d52877335d37b05fd))
* Add support for php-cs-fixer ([#78](https://github.com/stevearc/conform.nvim/issues/78)) ([e691eca](https://github.com/stevearc/conform.nvim/commit/e691ecaf41139a68ccb79fde824cb534ca11abd2))
* add templ support ([#73](https://github.com/stevearc/conform.nvim/issues/73)) ([28ecd5c](https://github.com/stevearc/conform.nvim/commit/28ecd5cf9132213417bff41d79477354cb81f50c))
* another utility for extending formatter arguments ([aada09c](https://github.com/stevearc/conform.nvim/commit/aada09c9cfea38187966ce47f34b9008e1104d21))
* new  utility function ([9e1fcd5](https://github.com/stevearc/conform.nvim/commit/9e1fcd5cafc42b5dfbe2e942ddbece0dada4e1d0))


### Bug Fixes

* rubocop succeeds even if some errors are not autocorrected ([#74](https://github.com/stevearc/conform.nvim/issues/74)) ([34daf23](https://github.com/stevearc/conform.nvim/commit/34daf23415e9d212697f79506039498db2b35240))

## [3.5.0](https://github.com/stevearc/conform.nvim/compare/v3.4.1...v3.5.0) (2023-09-22)


### Features

* add `bibtex-tidy` ([#69](https://github.com/stevearc/conform.nvim/issues/69)) ([f5e7f84](https://github.com/stevearc/conform.nvim/commit/f5e7f84fb27f05d9a3f3893634cbb6c7f7f89056))
* add dprint ([#71](https://github.com/stevearc/conform.nvim/issues/71)) ([0e2c97a](https://github.com/stevearc/conform.nvim/commit/0e2c97ab640f14f7da92278c731879efcb11f563))
* add mdformat ([#68](https://github.com/stevearc/conform.nvim/issues/68)) ([4a4c927](https://github.com/stevearc/conform.nvim/commit/4a4c92715b174b847ba0fcdccf9dfea71c8ed33e))
* add ruff formatter and improve ruff root finding ([#66](https://github.com/stevearc/conform.nvim/issues/66)) ([44e9e82](https://github.com/stevearc/conform.nvim/commit/44e9e8292d552f9a35498612a93dff934cc8802f))


### Bug Fixes

* `stylelint` and `markdownlint` when there are non-autofixable errors ([#70](https://github.com/stevearc/conform.nvim/issues/70)) ([5454fb5](https://github.com/stevearc/conform.nvim/commit/5454fb5a72a957b550fb7a0f5c4e84684c529920))

## [3.4.1](https://github.com/stevearc/conform.nvim/compare/v3.4.0...v3.4.1) (2023-09-19)


### Bug Fixes

* range formatting for LSP formatters ([#63](https://github.com/stevearc/conform.nvim/issues/63)) ([52280f0](https://github.com/stevearc/conform.nvim/commit/52280f032653e98dd6ecbb61488afcca39671964))

## [3.4.0](https://github.com/stevearc/conform.nvim/compare/v3.3.0...v3.4.0) (2023-09-18)


### Features

* add `squeeze_blanks` ([#62](https://github.com/stevearc/conform.nvim/issues/62)) ([3fa2a7b](https://github.com/stevearc/conform.nvim/commit/3fa2a7be8d91c3f0d7b79dde70d7849518cdc5bf))
* make lsp_fallback behavior more intuitive ([#59](https://github.com/stevearc/conform.nvim/issues/59)) ([1abbb82](https://github.com/stevearc/conform.nvim/commit/1abbb82bb8e519e652d8b31b12a311872e9090d1))

## [3.3.0](https://github.com/stevearc/conform.nvim/compare/v3.2.0...v3.3.0) (2023-09-17)


### Features

* '_' filetype to define fallback formatters ([a589750](https://github.com/stevearc/conform.nvim/commit/a589750635fcc5bb52c7e572cd853446c2c63855))
* add GNU/BSD indent ([#54](https://github.com/stevearc/conform.nvim/issues/54)) ([5abf6c2](https://github.com/stevearc/conform.nvim/commit/5abf6c2c89ff6ed7d17285ec1da759013463bfc7))
* Add rustywind formatter ([#56](https://github.com/stevearc/conform.nvim/issues/56)) ([a839ed1](https://github.com/stevearc/conform.nvim/commit/a839ed1384c21cbd8861f2850b552a4db10ead2f))
* add shellcheck ([#44](https://github.com/stevearc/conform.nvim/issues/44)) ([508ec8a](https://github.com/stevearc/conform.nvim/commit/508ec8a899e039a56f9110011125ab56284db1fa))
* alejandra formatter ([#52](https://github.com/stevearc/conform.nvim/issues/52)) ([e6552b5](https://github.com/stevearc/conform.nvim/commit/e6552b5c9b3a2b12bacb476b00c80c736b9f7963))
* allow running commands in a shell ([#49](https://github.com/stevearc/conform.nvim/issues/49)) ([fbb18a5](https://github.com/stevearc/conform.nvim/commit/fbb18a5b92e2f11aaaef379d74d4a1132a138cb3))
* format_on_save functions can return a callback as the second value ([1a568c6](https://github.com/stevearc/conform.nvim/commit/1a568c66f16650290fffcfbf5aefebe2d8254b83))
* provide a formatexpr ([#55](https://github.com/stevearc/conform.nvim/issues/55)) ([aa38b05](https://github.com/stevearc/conform.nvim/commit/aa38b05575dab57b813ddcd14780f65ff20a6d49))
* utility function to extend the built-in formatter args ([#50](https://github.com/stevearc/conform.nvim/issues/50)) ([cb5f939](https://github.com/stevearc/conform.nvim/commit/cb5f939ab27b2c2ef2e1d4ac6fe16c5ba6332f39))


### Bug Fixes

* `q` keymap in ConformInfo and `codespell` exit codes ([#53](https://github.com/stevearc/conform.nvim/issues/53)) ([d3fe431](https://github.com/stevearc/conform.nvim/commit/d3fe43167c7d96036c8c037ef1b4e03b448efbe7))
* ConformInfo shows available LSP formatters ([3aa2fd5](https://github.com/stevearc/conform.nvim/commit/3aa2fd5f828f8fcabd65605a41953aba1f0f5cb0))
* LSP formatter respects quiet = true ([5e4d258](https://github.com/stevearc/conform.nvim/commit/5e4d258f8eba4090b9a515ee9b77d8647394b2cd))
* unify timeout error message format with LSP ([0d963f8](https://github.com/stevearc/conform.nvim/commit/0d963f82add9ca4faf49b54fc28f57038742ded3))
* use non-deprecated health report functions if available ([#48](https://github.com/stevearc/conform.nvim/issues/48)) ([b436902](https://github.com/stevearc/conform.nvim/commit/b43690264ebcb152365d5b46faa6561f12ea062a))

## [3.2.0](https://github.com/stevearc/conform.nvim/compare/v3.1.0...v3.2.0) (2023-09-14)


### Features

* add `markdownlint`, `stylelint`, `codespell`, and `biome` ([#45](https://github.com/stevearc/conform.nvim/issues/45)) ([580ab18](https://github.com/stevearc/conform.nvim/commit/580ab1880e740f4aebbc72a05350461f3cdef53d))
* add buf as protobuf linter ([#43](https://github.com/stevearc/conform.nvim/issues/43)) ([2b73887](https://github.com/stevearc/conform.nvim/commit/2b73887fd75e1f6efc352cec6bd7e39157c3732e))
* add deno fmt ([#46](https://github.com/stevearc/conform.nvim/issues/46)) ([db7461a](https://github.com/stevearc/conform.nvim/commit/db7461afcf751023adeb346d833f2e5d40a420c4))
* add djlint ([#47](https://github.com/stevearc/conform.nvim/issues/47)) ([ead0257](https://github.com/stevearc/conform.nvim/commit/ead025784c8e31b8e45016e620c2f17a13ff741a))
* latexindent ([#42](https://github.com/stevearc/conform.nvim/issues/42)) ([502a358](https://github.com/stevearc/conform.nvim/commit/502a3583663ede11c8db1e9980db342b117d79f2))
* ruff ([#41](https://github.com/stevearc/conform.nvim/issues/41)) ([fdc4a0f](https://github.com/stevearc/conform.nvim/commit/fdc4a0f05c21012f2445a993ebdad700380dcfbf))


### Bug Fixes

* extra trailing newline for LSP formatters that replace entire file ([e18cdaf](https://github.com/stevearc/conform.nvim/commit/e18cdaf529b94465592d0c2afe1b62bc26155070))

## [3.1.0](https://github.com/stevearc/conform.nvim/compare/v3.0.0...v3.1.0) (2023-09-13)


### Features

* format_on_save and format_after_save can be functions ([dd5b2f2](https://github.com/stevearc/conform.nvim/commit/dd5b2f2f7ca01c2f28239cbbc7f97e6f9024cd94))


### Bug Fixes

* modify diff calculation to handle end-of-file newlines better ([#35](https://github.com/stevearc/conform.nvim/issues/35)) ([00a5288](https://github.com/stevearc/conform.nvim/commit/00a528818463b10d84699b2e0f4a960d5a4aeb5c))

## [3.0.0](https://github.com/stevearc/conform.nvim/compare/v2.3.0...v3.0.0) (2023-09-08)


### ⚠ BREAKING CHANGES

* remove run_all_formatters config option

### Features

* add beautysh, taplo, trim_newlines and trim_whitespace ([#29](https://github.com/stevearc/conform.nvim/issues/29)) ([37a2d65](https://github.com/stevearc/conform.nvim/commit/37a2d65bd2ee41540cc426d2cffef6d6f8648357))
* format() can always fall back to LSP formatting ([c3028b3](https://github.com/stevearc/conform.nvim/commit/c3028b327bc44335cc2b5c3014cd6d5c12a54ee4))
* syntax for using first available formatter ([2568d74](https://github.com/stevearc/conform.nvim/commit/2568d746abbadf66a03c62b568ee73d874cd8617))


### Code Refactoring

* remove run_all_formatters config option ([bd1aa02](https://github.com/stevearc/conform.nvim/commit/bd1aa02ef191410b2ea0b3ef5caabe06592d9c51))

## [2.3.0](https://github.com/stevearc/conform.nvim/compare/v2.2.0...v2.3.0) (2023-09-06)


### Features

* format() takes an optional callback ([#21](https://github.com/stevearc/conform.nvim/issues/21)) ([3f34f2d](https://github.com/stevearc/conform.nvim/commit/3f34f2de48e393b2ee289f2c8fa613c7eabae6d8))


### Bug Fixes

* callback should always be called ([eb3ebb6](https://github.com/stevearc/conform.nvim/commit/eb3ebb6d2d114f6476a8f8d21d74f99c6d231a53))

## [2.2.0](https://github.com/stevearc/conform.nvim/compare/v2.1.0...v2.2.0) (2023-08-31)


### Features

* apply changes as text edits using LSP utils ([#18](https://github.com/stevearc/conform.nvim/issues/18)) ([92393f0](https://github.com/stevearc/conform.nvim/commit/92393f02efadfb1d9f97c74c8feb853c1caea9de))

## [2.1.0](https://github.com/stevearc/conform.nvim/compare/v2.0.0...v2.1.0) (2023-08-30)


### Features

* add golines ([#11](https://github.com/stevearc/conform.nvim/issues/11)) ([e1d68a5](https://github.com/stevearc/conform.nvim/commit/e1d68a58fa29d2a24f1a976c3c60521ffb31f32e))
* add perlimports ([#13](https://github.com/stevearc/conform.nvim/issues/13)) ([e6e99af](https://github.com/stevearc/conform.nvim/commit/e6e99af64db3f364086aaf55b8b5854ccd62bac4))
* add perltidy ([#12](https://github.com/stevearc/conform.nvim/issues/12)) ([882b759](https://github.com/stevearc/conform.nvim/commit/882b75994af34fed3c4fe6f1a97ad58b352ec25f))
* add shellharden ([#14](https://github.com/stevearc/conform.nvim/issues/14)) ([863fb46](https://github.com/stevearc/conform.nvim/commit/863fb46fc7a7fa66fafb4bb8fd8093c700c472e5))
* add support for environment variables ([#8](https://github.com/stevearc/conform.nvim/issues/8)) ([03a37f1](https://github.com/stevearc/conform.nvim/commit/03a37f1b53d83af7aee10fc3ffee9f3a05d09e2e))
* display last few lines of the log file in :ConformInfo ([c9327f2](https://github.com/stevearc/conform.nvim/commit/c9327f2af541e4a17a6e2e05682122f8c8455d29))
* formatter config function is passed the buffer number ([#9](https://github.com/stevearc/conform.nvim/issues/9)) ([8b2a574](https://github.com/stevearc/conform.nvim/commit/8b2a5741e07e2d6d5e8103e5e12356d3a9f0b8ba))
* notify when formatter errors, and add notify_on_error config option ([#16](https://github.com/stevearc/conform.nvim/issues/16)) ([08dc913](https://github.com/stevearc/conform.nvim/commit/08dc913fb22d402a98d1d9733536f2876c6f6314))


### Bug Fixes

* shellharden ([#15](https://github.com/stevearc/conform.nvim/issues/15)) ([288068b](https://github.com/stevearc/conform.nvim/commit/288068b1b78c79e64054ef443afbf6f2f5145da4))

## [2.0.0](https://github.com/stevearc/conform.nvim/compare/v1.1.0...v2.0.0) (2023-08-29)


### ⚠ BREAKING CHANGES

* remove ability for formatter list to disable autoformat

### Features

* can silence notification when running formatters ([#7](https://github.com/stevearc/conform.nvim/issues/7)) ([a4d793e](https://github.com/stevearc/conform.nvim/commit/a4d793e941e8e497ab9149ed09c946473d795c1b))
* ConformInfo command for debugging formatter status ([1fd547f](https://github.com/stevearc/conform.nvim/commit/1fd547fe98a5100a041106e2bc353363ab0d5ad8))
* range formatting ([cddd536](https://github.com/stevearc/conform.nvim/commit/cddd536e087a9fd3d2c9ea5b0a44e46c7b4b54c2))


### Bug Fixes

* don't show 'no formatters' warning if none configured ([9376d37](https://github.com/stevearc/conform.nvim/commit/9376d37bd7ab456b7df8e3d6f1ba75c05b4e5a8f))
* keep window position stable when LSP formatting ([90e8a8d](https://github.com/stevearc/conform.nvim/commit/90e8a8d63c7d77d1872dca3da720abfa07271054))
* remove unnecessary notify ([6082883](https://github.com/stevearc/conform.nvim/commit/6082883585a5c61c7a5c6697517931bc6e39f546))
* stable ordering when specifying multiple formatters ([69c4495](https://github.com/stevearc/conform.nvim/commit/69c4495ab5ad3c07c3a4f3c2bcac2f070718b4cb))


### Code Refactoring

* remove ability for formatter list to disable autoformat ([d508ae8](https://github.com/stevearc/conform.nvim/commit/d508ae8f46b5b41e2806b412311719a941167c1a))

## [1.1.0](https://github.com/stevearc/conform.nvim/compare/v1.0.0...v1.1.0) (2023-08-28)


### Features

* new formatter: fish_indent ([#5](https://github.com/stevearc/conform.nvim/issues/5)) ([446aa57](https://github.com/stevearc/conform.nvim/commit/446aa570048586f9c13f1ea88e280567f336691e))


### Bug Fixes

* gracefully handle another timeout case ([500d24d](https://github.com/stevearc/conform.nvim/commit/500d24dc1a2447a3c8f3f4f756f40bd27ff0b283))
* no need to save/restore window view ([5bc69d5](https://github.com/stevearc/conform.nvim/commit/5bc69d500a14fb06bf8f36005f76a7825be25931))

## 1.0.0 (2023-08-25)


### Features

* first working version ([eb5987e](https://github.com/stevearc/conform.nvim/commit/eb5987e9dd40ce1e27c9c07e41d09571f1bd876e))


### Bug Fixes

* don't modify files when no styling changes ([08b54ba](https://github.com/stevearc/conform.nvim/commit/08b54ba11e29e6df9f83c02539976331617a412c))
* ensure real buffer numbers get logged ([33ee8ba](https://github.com/stevearc/conform.nvim/commit/33ee8ba8cb6f29caec1edf01fa4987bbae52f18b))
* notification when no formatters available ([a757225](https://github.com/stevearc/conform.nvim/commit/a75722517d17d749a5ee86c8a3bbb098a61265fc))
* set a cwd for stylua ([a22781e](https://github.com/stevearc/conform.nvim/commit/a22781e0c3b609a5f90095f388589744567476c7))
