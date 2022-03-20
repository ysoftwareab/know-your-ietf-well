#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source ${DIR}/update.util.sh

mkdir -p ${DIR}/id-archive
cd ${DIR}/id-archive
reset_git_ref refs/rsync/id-archive

rsync -avz --delete --delete-excluded \
    --filter "protect .git/" \
    --filter "protect .gitattributes" \
    --include "*.html" \
    --include "*.json" \
    --include "*.txt" \
    --include "*.txt1" \
    --include "*.txt%" \
    --include "*.text" \
    --include "*.tx" \
    --include "*.utf8" \
    --include "draft-ietf-apex-core-06" \
    --include "draft-ietf-dhc-v4-threat-analysis-00" \
    --include "draft-ietf-ion-scsp-m" \
    --include "draft-ietf-lemonade-" \
    --include "draft-olson-sipping-content-indirect-00" \
    --include "draft-vasseur-isis-te-caps-" \
    --exclude "*" \
    rsync.ietf.org::id-archive .

update_git_ref refs/rsync/id-archive
