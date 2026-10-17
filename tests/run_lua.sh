#!/usr/bin/env bash
# tests/lua/*_spec.lua 를 각각 headless nvim으로 실행한다
cd "$(dirname "$0")/.." || exit 1
fail=0
for f in tests/lua/*_spec.lua; do
    if nvim --headless -u NONE -l "$f"; then
        echo "PASS $f"
    else
        echo "FAIL $f"
        fail=1
    fi
done
exit $fail
