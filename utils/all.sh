#!/usr/bin/env bash

# 1. build with hbc
# 2. create hashes
# 3. commit and push

set -e

# CHECK PATH
[[ $PWD = */utils ]] && cd ..
[[ $PWD = */monero-bash ]]

# HBC
hbc

# HASH
utils/hash.sh

# PUSH
git add .
if [[ $1 ]]; then
	git commit -m "$1"
else
	git commit -m "hbc"
fi
git push
