# Changelog

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
