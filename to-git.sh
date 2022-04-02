#!/usr/bin/env bash
set -euo pipefail

# parallelism
CORES=16

export GIT_AUTHOR_DATE="1970-01-01T00:00:00Z"
export GIT_COMMITTER_DATE="1970-01-01T00:00:00Z"

export GIT_USER_NAME="Andrei Neculau"
export GIT_USER_EMAIL="andrei.neculau@gmail.com"

function to_git() {
    local i=$1
    local DIR=git/rfc${i}

    [[ ! -e "${DIR}" ]] || return 0

    local f="rfcs/rfc${i}.json"
    [[ -e "$f" ]] || return 0

    >&2 echo "[DO  ] Creating a git history for RFC${i} in ${DIR} ."

    # rm -rf ${DIR}
    mkdir -p ${DIR}
    git -C ${DIR} init
    git -c "commit.gpgsign=false" -c "user.name=${GIT_USER_NAME}" -c "user.email=${GIT_USER_EMAIL}" \
        -C ${DIR} commit --allow-empty -m "initial commit"
    git -C ${DIR} remote add origin git@github.com:ysoftwareab/ietf-rfcs-abnf.git

    DRAFT=$(cat $f | jq -r ".draft" || true)
    [[ ! -n "${DRAFT}" ]] || {
        local DRAFT_NAME=$(echo "${DRAFT}" | sed "s|\(.*\)-\([0-9]\+\)$|\1|")
        local DRAFT_VSN=$(echo "${DRAFT}" | sed "s|\(.*\)-\([0-9]\+\)$|\2|")
        local drafti
        for drafti in $(seq 0 ${DRAFT_VSN}); do
            local draftii=$(printf "%${#DRAFT_VSN}s" "${drafti}" | tr " " "0")
            [[ -f id-archive/${DRAFT_NAME}-${draftii}.txt ]] || continue

            {
                >&2 echo "[INFO] Commiting RFC${i} ${DRAFT_NAME}-${draftii}..."
                git -C ${DIR} reset --hard HEAD
                git -C ${DIR} clean -xdf .
                git -C ${DIR} ls-files | xargs -I{} rm ${DIR}/{}

                cp rfcs/rfc${i}.json ${DIR}
                cp id-archive/${DRAFT_NAME}-${draftii}.* ${DIR}
                cp id-archive-abnf/${DRAFT_NAME}-${draftii}.* ${DIR} || true
                cp id-archive-pdf/${DRAFT_NAME}-${draftii}.* ${DIR} || true
                git -C ${DIR} add .
                git -c "commit.gpgsign=false" -c "user.name=${GIT_USER_NAME}" -c "user.email=${GIT_USER_EMAIL}" \
                    -C ${DIR} commit -m "${DRAFT_NAME}-${draftii}"
            } || true
        done
    }

    {
        >&2 echo "[INFO] Commiting RFC${i}..."
        git -C ${DIR} reset --hard HEAD
        git -C ${DIR} clean -xdf .
        git -C ${DIR} ls-files | xargs -I{} rm ${DIR}/{}

        cp rfcs/rfc${i}.json ${DIR}
        cp rfcs/rfc${i}.* ${DIR}
        cp rfcs-abnf/rfc${i}.* ${DIR} || true
        cp rfcs-pdf/rfc${i}.* ${DIR} || true
        git -C ${DIR} add .
        git -c "commit.gpgsign=false" -c "user.name=${GIT_USER_NAME}" -c "user.email=${GIT_USER_EMAIL}" \
            -C ${DIR} commit -m "RFC${i}"
    } || true

    [[ ! -f "rfcs-errata/rfc${i}.errata-inline.html" ]] || {
        >&2 echo "[INFO] Commiting errata for RFC${i}..."
        git -C ${DIR} reset --hard HEAD
        git -C ${DIR} clean -xdf .
        git -C ${DIR} ls-files | xargs -I{} rm ${DIR}/{}

        cp rfcs/rfc${i}.json ${DIR}
        cp rfcs-errata/rfc${i}.* ${DIR}
        git -C ${DIR} add .
        git -c "commit.gpgsign=false" -c "user.name=${GIT_USER_NAME}" -c "user.email=${GIT_USER_EMAIL}" \
            -C ${DIR} commit -m "RFC${i} errata"
    } || true

    >&2 echo "[DONE] Creating a git history for RFC${i} in ${DIR} ."

    >&2 echo "[INFO] Force-pushing git history for RFC${i} to remote origin..."
    git -C ${DIR} push -f origin head:refs/heads/rfc${i}
}
export -f to_git

parallel -j ${CORES} "to_git {}" ::: $(seq $(cat count) 10000)
