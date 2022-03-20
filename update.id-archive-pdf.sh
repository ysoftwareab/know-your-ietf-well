#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source ${DIR}/update.util.sh

mkdir -p ${DIR}/id-archive-pdf
cd ${DIR}/id-archive-pdf
reset_git_ref refs/rsync/id-archive-pdf

rsync -avz --delete --delete-excluded \
    --filter "protect .git/" \
    --filter "protect .gitattributes" \
    --include "*.pdf" \
    --exclude "*" \
    rsync.ietf.org::id-archive .

update_git_ref refs/rsync/id-archive-pdf
