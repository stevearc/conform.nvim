#!/bin/bash

set -e

if [ -e "tests/fake_formatter_output" ]; then
	cat tests/fake_formatter_output
else
	cat
fi

if [ "$1" = "--fail" ]; then
	echo "failure" >&2
	exit 1
elif [ "$1" = "--timeout" ]; then
	sleep 4
fi

