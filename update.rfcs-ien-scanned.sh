#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source ${DIR}/update.util.sh

mkdir -p ${DIR}/rfcs-ien-scanned
cd ${DIR}/rfcs-ien-scanned
reset_git_ref refs/rsync/rfcs-ien-scanned

rsync -avz --delete --delete-excluded \
    --filter "protect .git/" \
    --filter "protect .gitattributes" \
    --include "ien/scanned/*" \
    --exclude "*" \
    ftp.rfc-editor.org::rfcs .

update_git_ref refs/rsync/rfcs-ien-scanned
