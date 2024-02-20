# Changelog

## [5.3.0](https://github.com/stevearc/conform.nvim/compare/v5.2.1...v5.3.0) (2024-02-20)


### Features

* add awk formatter ([#286](https://github.com/stevearc/conform.nvim/issues/286)) ([338c307](https://github.com/stevearc/conform.nvim/commit/338c3070ae7f7028185ae6123541c2ca71cfe7ff))
* add biome-check formatter ([#287](https://github.com/stevearc/conform.nvim/issues/287)) ([5a71b60](https://github.com/stevearc/conform.nvim/commit/5a71b6064ec6ecf0fff91af67e95200aae9e9562))
* add fantomas formatter ([#302](https://github.com/stevearc/conform.nvim/issues/302)) ([0d99714](https://github.com/stevearc/conform.nvim/commit/0d997149a0472ab811bcfdca5dc45d9db483f949))
* Add reorder-python-imports formatter ([#284](https://github.com/stevearc/conform.nvim/issues/284)) ([9a07f60](https://github.com/stevearc/conform.nvim/commit/9a07f60f7499cdc76ed40af62bb9a50ac928d7d2))
* add ReScript formatter ([#293](https://github.com/stevearc/conform.nvim/issues/293)) ([a34b66f](https://github.com/stevearc/conform.nvim/commit/a34b66f9a4a8f4fb8e270ebfa9c8836fdb8381c1))
* add terragrunt_hclfmt formatter ([#278](https://github.com/stevearc/conform.nvim/issues/278)) ([375258f](https://github.com/stevearc/conform.nvim/commit/375258f1fe1500f175d7135aef1dc6a87dbd83b2))
* add twig-cs-fixer ([#304](https://github.com/stevearc/conform.nvim/issues/304)) ([766812b](https://github.com/stevearc/conform.nvim/commit/766812b0e830c2e40613f99f89102d8840431c6a))
* add yq formatter ([#288](https://github.com/stevearc/conform.nvim/issues/288)) ([15c4a02](https://github.com/stevearc/conform.nvim/commit/15c4a0273bb5468004bb46f632dc5326bc5634d7))


### Bug Fixes

* `swift_format` doesn't respect `.swift-format` file ([#283](https://github.com/stevearc/conform.nvim/issues/283)) ([4588008](https://github.com/stevearc/conform.nvim/commit/4588008a7c5b57fbff97fdfb529c059235cdc7ee))
* set a cwd for biome ([#282](https://github.com/stevearc/conform.nvim/issues/282)) ([03feeb5](https://github.com/stevearc/conform.nvim/commit/03feeb5024a4b44754d63dec55b79b8133a8ea9f))

## [5.2.1](https://github.com/stevearc/conform.nvim/compare/v5.2.0...v5.2.1) (2024-01-21)


### Bug Fixes

* handle windows line endings ([#274](https://github.com/stevearc/conform.nvim/issues/274)) ([9a785eb](https://github.com/stevearc/conform.nvim/commit/9a785eb8f0199ac47ce8bb9e9b6103de5ad8e3a7))

## [5.2.0](https://github.com/stevearc/conform.nvim/compare/v5.1.0...v5.2.0) (2024-01-16)


### Features

* add cue_fmt formatter ([#265](https://github.com/stevearc/conform.nvim/issues/265)) ([03de11a](https://github.com/stevearc/conform.nvim/commit/03de11a0dcf686fda58d64a895483e284dd0c5b6))
* Add dry_run option and report if buffer was/would be changed by formatters ([#273](https://github.com/stevearc/conform.nvim/issues/273)) ([e0276bb](https://github.com/stevearc/conform.nvim/commit/e0276bb32e9b33ece11fef2a5cfc8fb2108df0df))
* add opa_fmt formatter ([#267](https://github.com/stevearc/conform.nvim/issues/267)) ([a4e84d5](https://github.com/stevearc/conform.nvim/commit/a4e84d56d5959dae685c5e22db202cd86b5b322b))
* add xmllint formatter ([#259](https://github.com/stevearc/conform.nvim/issues/259)) ([c50ba4b](https://github.com/stevearc/conform.nvim/commit/c50ba4baad90f02840cc31ee745b09078b7a1777))
* **formatexpr:** don't require LSP range formatting if operating on whole file ([#272](https://github.com/stevearc/conform.nvim/issues/272)) ([47ceff6](https://github.com/stevearc/conform.nvim/commit/47ceff644e9d00872f410be374cc973eefa20ba9))


### Bug Fixes

* **black:** formatting excluded files results in blank buffer ([#254](https://github.com/stevearc/conform.nvim/issues/254)) ([c4b2efb](https://github.com/stevearc/conform.nvim/commit/c4b2efb8aee4af0ef179a9b49ba401de3c4ef5d2))
* copy input parameters for will_fallback_lsp ([ad347d7](https://github.com/stevearc/conform.nvim/commit/ad347d70e66737a8b9d62c19df1c0e2c5b2cd008))
* injected formatter works on nightly ([#270](https://github.com/stevearc/conform.nvim/issues/270)) ([229e9ab](https://github.com/stevearc/conform.nvim/commit/229e9ab5d6e90bc5e6d24141dce3cc28ba95293a))
* LSP deprecated method warning on nvim nightly ([75e7c5c](https://github.com/stevearc/conform.nvim/commit/75e7c5c7eb5fbd53f8b12dc420b31ec70770b231))
* pass explicit bufnr to avoid race conditions ([#260](https://github.com/stevearc/conform.nvim/issues/260)) ([a8e3935](https://github.com/stevearc/conform.nvim/commit/a8e39359814b7b5df5fac7423b4dc93826d64464))
* set a cwd for djlint ([#264](https://github.com/stevearc/conform.nvim/issues/264)) ([0802406](https://github.com/stevearc/conform.nvim/commit/08024063232a7bd38ecdfaf89f06162a5ba2df91))
* set a cwd for dprint ([#263](https://github.com/stevearc/conform.nvim/issues/263)) ([e6c1353](https://github.com/stevearc/conform.nvim/commit/e6c135338257f69c018e8351a6e5f63683f86318))

## [5.1.0](https://github.com/stevearc/conform.nvim/compare/v5.0.0...v5.1.0) (2023-12-26)


### Features

* add fnlfmt formatter ([#247](https://github.com/stevearc/conform.nvim/issues/247)) ([af6643a](https://github.com/stevearc/conform.nvim/commit/af6643afa10e17c0228da97c84d4c32f144a6ad3))
* ConformInfo shows path to executable ([#244](https://github.com/stevearc/conform.nvim/issues/244)) ([fb9b050](https://github.com/stevearc/conform.nvim/commit/fb9b0500270ba05b89cc27cd8b7762443bcfae22))
* **prettier:** add `options` for configuring prettier parser based on filetype and extension ([#241](https://github.com/stevearc/conform.nvim/issues/241)) ([8df1bed](https://github.com/stevearc/conform.nvim/commit/8df1bed7b8de9cf40476996fb5ab73ed667aed35))


### Bug Fixes

* crash in error handling ([4185249](https://github.com/stevearc/conform.nvim/commit/41852493b5abd7b5a0fd61ff007994c777a08ec9))
* **formatexpr:** does not fallback to the built-in formatexpr ([#238](https://github.com/stevearc/conform.nvim/issues/238)) ([48bc999](https://github.com/stevearc/conform.nvim/commit/48bc9996ebfe90e7766f46338360f75fd6ecb174))
* **injected:** code block at end of markdown file ([9245b61](https://github.com/stevearc/conform.nvim/commit/9245b616d1edb159775a0832c03324bf92884494))
* **injected:** handle inline injections ([#251](https://github.com/stevearc/conform.nvim/issues/251)) ([f245cca](https://github.com/stevearc/conform.nvim/commit/f245cca8ad42c9d344b53a18c3fc1a3c6724c2d4))
* **prettier:** use correct prettier executable on windows ([#236](https://github.com/stevearc/conform.nvim/issues/236)) ([7396fc0](https://github.com/stevearc/conform.nvim/commit/7396fc0208539e2bd70e3e446f27529e28dba12b))
* **rubocop:** pass --server for faster execution ([#246](https://github.com/stevearc/conform.nvim/issues/246)) ([0ec6edd](https://github.com/stevearc/conform.nvim/commit/0ec6edd67689e8df6726b83333106bcec13c36d4))

## [5.0.0](https://github.com/stevearc/conform.nvim/compare/v4.3.0...v5.0.0) (2023-12-07)


### ⚠ BREAKING CHANGES

* formatter config functions take self as first argument ([#233](https://github.com/stevearc/conform.nvim/issues/233))

### Features

* add asmfmt ([#239](https://github.com/stevearc/conform.nvim/issues/239)) ([a5ef494](https://github.com/stevearc/conform.nvim/commit/a5ef4943f6382f36a5a8d6e16eb0a0c60af5e7a5))
* add joker for clojure formatting ([#240](https://github.com/stevearc/conform.nvim/issues/240)) ([6b13100](https://github.com/stevearc/conform.nvim/commit/6b1310014ceec5752fd5859f9cc62ef7c93d72b2))


### Code Refactoring

* formatter config functions take self as first argument ([#233](https://github.com/stevearc/conform.nvim/issues/233)) ([659838f](https://github.com/stevearc/conform.nvim/commit/659838ff4244ef6af095395ce68aaaf99fa8e696))

## [4.3.0](https://github.com/stevearc/conform.nvim/compare/v4.2.0...v4.3.0) (2023-12-07)


### Features

* add `auto-optional` ([#196](https://github.com/stevearc/conform.nvim/issues/196)) ([9156364](https://github.com/stevearc/conform.nvim/commit/9156364c23cff19734a0055377321c22b1484c0f))
* add `typos` ([#214](https://github.com/stevearc/conform.nvim/issues/214)) ([d86c186](https://github.com/stevearc/conform.nvim/commit/d86c186ba910d28a6266c4d6210578dca984f3e3))
* add autocorrect ([#223](https://github.com/stevearc/conform.nvim/issues/223)) ([cd81d21](https://github.com/stevearc/conform.nvim/commit/cd81d215d39b16186186a1539c71b48705bb081d))
* add beancount formatter ([#212](https://github.com/stevearc/conform.nvim/issues/212)) ([c0924a6](https://github.com/stevearc/conform.nvim/commit/c0924a61e079d94f0be40da2d4188210c6e4ffea))
* add cbfmt ([#198](https://github.com/stevearc/conform.nvim/issues/198)) ([aa36bc0](https://github.com/stevearc/conform.nvim/commit/aa36bc05563d5390a2ef67956d72560048acdc2e))
* add fourmolu support ([#209](https://github.com/stevearc/conform.nvim/issues/209)) ([e688864](https://github.com/stevearc/conform.nvim/commit/e688864883aa4f468cc73a4c1db661c7c94addc4))
* add jsonnetfmt ([#230](https://github.com/stevearc/conform.nvim/issues/230)) ([769dde8](https://github.com/stevearc/conform.nvim/commit/769dde8ddccf8338c68da706e46fd2fb004e6455))
* add packer formatter ([#202](https://github.com/stevearc/conform.nvim/issues/202)) ([a0cabaa](https://github.com/stevearc/conform.nvim/commit/a0cabaaf5c94137c8dc34043244a34b552860af6))
* add pangu ([#188](https://github.com/stevearc/conform.nvim/issues/188)) ([f0780e2](https://github.com/stevearc/conform.nvim/commit/f0780e2231df2e4751e31db32c1545872412ba75))
* add phpinsights ([#170](https://github.com/stevearc/conform.nvim/issues/170)) ([5235405](https://github.com/stevearc/conform.nvim/commit/5235405cc6d4ac98dc9008ffa850038e3325bbce))
* add styler formatter for R ([#184](https://github.com/stevearc/conform.nvim/issues/184)) ([6afc64e](https://github.com/stevearc/conform.nvim/commit/6afc64e9f36cbae35c2a8b6852d0b91c9807a72a))
* add support for buildifier ([#216](https://github.com/stevearc/conform.nvim/issues/216)) ([e478834](https://github.com/stevearc/conform.nvim/commit/e478834227e0958e21a54f31c9cd896a3a8bdde0))
* add support for sqlfluff ([#213](https://github.com/stevearc/conform.nvim/issues/213)) ([e8c8683](https://github.com/stevearc/conform.nvim/commit/e8c8683a00fb932dfe669e1c96832da12b8054bd))


### Bug Fixes

* **biome:** perform formatting over stdin ([#220](https://github.com/stevearc/conform.nvim/issues/220)) ([eddd643](https://github.com/stevearc/conform.nvim/commit/eddd6431370814caacec1d1e3c7d6d95d41b133d))
* **biome:** use binary from node_modules ([#226](https://github.com/stevearc/conform.nvim/issues/226)) ([5bf1405](https://github.com/stevearc/conform.nvim/commit/5bf1405fd234d469243ea6f394e0aeec9ea53bd8))
* injected formatter adds language to file extension ([#199](https://github.com/stevearc/conform.nvim/issues/199)) ([e2b889e](https://github.com/stevearc/conform.nvim/commit/e2b889e26586acf30dda7b4a5c3f1a063bc18f18))
* injected parser shouldn't format combined injections ([#205](https://github.com/stevearc/conform.nvim/issues/205)) ([eeef888](https://github.com/stevearc/conform.nvim/commit/eeef88849fb644d84a5856524adf10d0ad2d7cbe))
* invalid prettier configuration in last commit ([e8ac7f1](https://github.com/stevearc/conform.nvim/commit/e8ac7f1a9a3973ecce6942b2f26d16e65902aa70))
* range format method for async formatters and injected ([a36c68d](https://github.com/stevearc/conform.nvim/commit/a36c68d2cd551e49883ddb2492c178d915567f58))
* respect excluded-files-config from `typos.toml` ([#219](https://github.com/stevearc/conform.nvim/issues/219)) ([db9da1a](https://github.com/stevearc/conform.nvim/commit/db9da1aa57e8be683ada1b1e5f8129c28d2576eb))
* show more logs in ConformInfo when log level is TRACE ([0963118](https://github.com/stevearc/conform.nvim/commit/0963118e60e0895e2e4842aeffc67cdf9e2bcd10))
* various fixes for the `injected` formatter ([#235](https://github.com/stevearc/conform.nvim/issues/235)) ([07fcbfc](https://github.com/stevearc/conform.nvim/commit/07fcbfc13490786f5983bce3f404643fcfd83775))

## [4.2.0](https://github.com/stevearc/conform.nvim/compare/v4.1.0...v4.2.0) (2023-11-09)


### Features

* add typstfmt ([#180](https://github.com/stevearc/conform.nvim/issues/180)) ([b1f1194](https://github.com/stevearc/conform.nvim/commit/b1f1194338c96d385ec6370ac734ab63c0289776))


### Bug Fixes

* catch jobstart errors ([#183](https://github.com/stevearc/conform.nvim/issues/183)) ([dcbe650](https://github.com/stevearc/conform.nvim/commit/dcbe650bd4811cefe5a885fafb6309c7d592bda6))
* injected formatter not working ([#187](https://github.com/stevearc/conform.nvim/issues/187)) ([68abada](https://github.com/stevearc/conform.nvim/commit/68abada5a348f448eabdbd7d71884c195969484f))
* nonzero exit code on :wq ([#176](https://github.com/stevearc/conform.nvim/issues/176)) ([161d95b](https://github.com/stevearc/conform.nvim/commit/161d95bfbb1ad1a2b89ba2ea75ca1b5e012a111e))
* rename `astgrep` to `ast-grep` ([#178](https://github.com/stevearc/conform.nvim/issues/178)) ([bfa69a9](https://github.com/stevearc/conform.nvim/commit/bfa69a942e19159d3a3e958a5be85cb7cdae19a7))

## [4.1.0](https://github.com/stevearc/conform.nvim/compare/v4.0.0...v4.1.0) (2023-11-05)


### Features

* add `ast-grep` ([#177](https://github.com/stevearc/conform.nvim/issues/177)) ([fa3cf1c](https://github.com/stevearc/conform.nvim/commit/fa3cf1c40716492fd0df0c3dedd54c8018f9ea70))
* add CSharpier ([#165](https://github.com/stevearc/conform.nvim/issues/165)) ([b2368ff](https://github.com/stevearc/conform.nvim/commit/b2368ff18a9dd9452170d3a6f41b1f872ae5d0b2))
* add markdownlint-cli2 ([#171](https://github.com/stevearc/conform.nvim/issues/171)) ([9bb3a94](https://github.com/stevearc/conform.nvim/commit/9bb3a940389dda796192a477a016069472692526))
* add mdslw markdown formatter ([#175](https://github.com/stevearc/conform.nvim/issues/175)) ([369c7fe](https://github.com/stevearc/conform.nvim/commit/369c7fe690b3fec0ecdd7c17faeebf3f8113a0f5))
* add pretty-php ([#161](https://github.com/stevearc/conform.nvim/issues/161)) ([4653408](https://github.com/stevearc/conform.nvim/commit/4653408d5c270168e31ffd0585d1cf2de27fc827))
* add puppet-lint formatter ([#153](https://github.com/stevearc/conform.nvim/issues/153)) ([0219648](https://github.com/stevearc/conform.nvim/commit/0219648cd9a2bafc13fda64903e49fda5db0016b))
* add tlint ([#162](https://github.com/stevearc/conform.nvim/issues/162)) ([2538784](https://github.com/stevearc/conform.nvim/commit/253878436e2b6d73dfd91ccf0ac12d04cc683d34))
* add usort ([#167](https://github.com/stevearc/conform.nvim/issues/167)) ([f7766d2](https://github.com/stevearc/conform.nvim/commit/f7766d2fbe23f0f22a3db1513beba7d03a8dc261))
* allow formatters_by_ft to be a function ([#174](https://github.com/stevearc/conform.nvim/issues/174)) ([0bbe838](https://github.com/stevearc/conform.nvim/commit/0bbe83830be5a07a1161bb1a23d7280310656177))
* gn build file format cmd ([#155](https://github.com/stevearc/conform.nvim/issues/155)) ([3716927](https://github.com/stevearc/conform.nvim/commit/37169273a0776752a3c01cbe01227e275b642b89))
* zprint formatter for clojure ([#146](https://github.com/stevearc/conform.nvim/issues/146)) ([2800552](https://github.com/stevearc/conform.nvim/commit/280055248661a4fc7b692db2d5ee80a465ebb577))


### Bug Fixes

* **formatexpr:** use default formatexpr if no formatters or LSP clients ([#55](https://github.com/stevearc/conform.nvim/issues/55)) ([278bcd8](https://github.com/stevearc/conform.nvim/commit/278bcd8bf2017e187e963b515017341fdd87fe2f))
* **rubyfmt:** exit code 1 should not be a success ([#157](https://github.com/stevearc/conform.nvim/issues/157)) ([e4ecb6e](https://github.com/stevearc/conform.nvim/commit/e4ecb6e8ed3163c86d7e647f1dc3d94de77ca687))

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
