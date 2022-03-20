#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source ${DIR}/update.util.sh

mkdir -p ${DIR}/rfcs-errata
cd ${DIR}/rfcs-errata
reset_git_ref refs/rsync/rfcs-errata

find ${DIR}/rfcs -type f -name "*.json" | while read -r f; do
    ERRATA_URL=$(cat $f | jq -r ".errata_url" || echo "null")
    [[ "${ERRATA_URL}" != "null" ]] || continue

    g="${f#"${DIR}/rfcs/"}"
    [[ ! -e "${g%.json}.errata.html" ]] || continue
    >&2 echo "[INFO] Processing $f..."
    mkdir -p "$(dirname $g)"
    curl -fqsS "${ERRATA_URL}" > "${g%.json}.errata.html"
    {
        curl -fqsS "https://www.rfc-editor.org/rfc/inline-errata/${g%.json}.html" > "${g%.json}.errata-inline.html"
        cat "${g%.json}.errata-inline.html" | ${DIR}/node_modules/.bin/html-to-text --tables=true > "${g%.json}.errata-inline.txt"
        cat "${g%.json}.errata-inline.txt" | ${DIR}/aex > "${g%.json}.errata-inline.abnf"
    } || true
    # [[ -s "${g%.json}.errata-inline.html" ]] || rm "${g%.json}.errata-inline.html"
    # [[ -s "${g%.json}.errata-inline.txt" ]] || rm "${g%.json}.errata-inline.txt"
    # [[ -s "${g%.json}.errata-inline.abnf" ]] || rm "${g%.json}.errata-inline.abnf"
done

update_git_ref refs/rsync/rfcs-errata
