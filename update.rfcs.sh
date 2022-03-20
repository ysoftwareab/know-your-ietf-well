#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source ${DIR}/update.util.sh

mkdir -p ${DIR}/rfcs
cd ${DIR}/rfcs
reset_git_ref refs/rsync/rfcs

rsync -avz --delete --delete-excluded \
    --filter "protect .git/" \
    --filter "protect .gitattributes" \
    --include "*.html" \
    --include "*.json" \
    --include "*.txt" \
    --exclude "*" \
    --exclude "ien/scanned/*" \
    ftp.rfc-editor.org::rfcs .

update_git_ref refs/rsync/rfcs
