#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source ${DIR}/update.util.sh

mkdir -p ${DIR}/rfcs-abnf
cd ${DIR}/rfcs-abnf
reset_git_ref refs/rsync/rfcs-abnf

find ${DIR}/rfcs -type f -name "*.txt" | while read -r f; do
    g="${f#"${DIR}/rfcs/"}"
    [[ ! -e "${g%.txt}.abnf" ]] || continue
    >&2 echo "[INFO] Processing $f..."
    mkdir -p "$(dirname $g)"
    cat "$f" | ${DIR}/aex > "${g%.txt}.abnf"
    # [[ -s "${g%.txt}.abnf" ]] || rm "${g%.txt}.abnf"
done

update_git_ref refs/rsync/rfcs-abnf
