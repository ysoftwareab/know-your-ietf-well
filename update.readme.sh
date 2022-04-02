#!/usr/bin/env bash
set -euo pipefail

function create_readme() {
    local i=$1

    local f="rfcs/rfc${i}.txt"
    [[ -e "$f" ]] || return 0

    echo "RFC${i}" >> list.txt
    echo "* [RFC${i}](https://github.com/ysoftwareab/know-your-ietf-well/tree/rfc${i})" >> list.md
    echo "${i}" > count
}

# rfc
rm -f list.{md,txt}
for i in $(ls rfcs | sort -V | grep "^rfc[0-9]\+.txt$" | sed "s|^rfc||" | sed "s/\.txt//"); do
    create_readme $i
done

# draft
rm -f list.draft.{md,txt}
comm -23 \
    <(ls id-archive | sort -V | grep "^draft-" | grep "\-[0-9]\+.txt" | sed "s|\(.*\)-\([0-9]\+\)\.txt$|\1|" | sort -u) \
    <(jq -r ".draft" rfcs/*.json | sed "s/^\s+//" | sed "s/\s+$//" | sed "s|\(.*\)-\([0-9]\+\)$|\1|" | sort -u) | \
    while read -r DRAFT_NAME; do
        echo "${DRAFT_NAME}" >> list.draft.txt
        echo "* [${DRAFT_NAME}](https://github.com/ysoftwareab/know-your-ietf-well/tree/${DRAFT_NAME})" >> list.draft.md
    done
