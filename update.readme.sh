#!/usr/bin/env bash
set -euo pipefail

function create_readme() {
    local i=$1

    local f="rfcs/rfc${i}.txt"
    [[ -e "$f" ]] || return 0

    echo "* [RFC${i}](https://github.com/ysoftwareab/know-your-ietf-well/tree/rfc${i})" >> list.md
    echo "${i}" > count
}

for i in $(seq $(cat count) 10000); do
    create_readme $i
done
