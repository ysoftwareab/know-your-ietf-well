#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

cd ${DIR}

./update.rfcs.sh
./update.rfcs-pdf.sh
# ./update.rfcs-ien-scanned.sh
./update.rfcs-abnf.sh

./update.id-archive.sh
./update.id-archive-pdf.sh
./update.id-archive-abnf.sh

./update.readme.sh
