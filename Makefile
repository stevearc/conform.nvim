.PHONY: doc test lint fastlint all

all: doc lint test

doc: scripts/nvim_doc_tools
	python scripts/main.py generate

test:
	./run_tests.sh

fastlint: scripts/nvim_doc_tools
	python scripts/main.py lint
	luacheck lua tests --formatter plain
	stylua --check lua tests

lint: scripts/nvim-typecheck-action fastlint
	./scripts/nvim-typecheck-action/typecheck.sh lua

scripts/nvim_doc_tools:
	git clone https://github.com/stevearc/nvim_doc_tools scripts/nvim_doc_tools

scripts/nvim-typecheck-action:
	git clone https://github.com/stevearc/nvim-typecheck-action scripts/nvim-typecheck-action
