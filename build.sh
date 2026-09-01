#!/usr/bin/env sh
set -eu

git submodule update --init --recursive
mkdir -p build
./vendor/zap-toml/build_lib.sh

# Bootstrap-only: thor's own dependency-restore mechanism (github.zp)
# needs a working thor binary to run, which doesn't exist yet at this
# stage, so vendor zap-requests directly via git instead. Reads the
# pinned commit straight out of thor.toml so there's only one place
# that needs updating if the dependency is ever bumped. (Needs git
# access to the repo -- zap-requests is private, so this step relies on
# git/gh already having credentials, same as any private dependency.)
if [ ! -d vendor/zap-requests ]; then
    zap_requests_commit=$(grep '"zap-requests"' thor.toml | sed -n 's/.*commit = "\([^"]*\)".*/\1/p')
    git clone https://github.com/zap-tooling/zap-requests vendor/zap-requests
    (cd vendor/zap-requests && git checkout "$zap_requests_commit")
fi

./tools/zapc-no-pie src/main.zp -o build/thor --import-map @toml=./vendor/zap-toml/src --import-map @zap-requests=./vendor/zap-requests/src -Lvendor/zap-toml/lib -lztoml
