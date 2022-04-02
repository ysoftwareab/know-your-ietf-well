#!/usr/bin/env bash
set -euo pipefail

# parallelism
CORES=16

export GIT_AUTHOR_DATE="1970-01-01T00:00:00Z"
export GIT_COMMITTER_DATE="1970-01-01T00:00:00Z"

export GIT_USER_NAME="Andrei Neculau"
export GIT_USER_EMAIL="andrei.neculau@gmail.com"

function init_rfc_git() {
    local i=$1
    local DIR=$2
    local DRAFT=$3

    # rm -rf ${DIR}
    mkdir -p ${DIR}
    [[ -d ${DIR}/.git ]] || {
        git -C ${DIR} init
        git -c "commit.gpgsign=false" -c "user.name=${GIT_USER_NAME}" -c "user.email=${GIT_USER_EMAIL}" \
            -C ${DIR} commit --allow-empty -m "initial commit"
        git -C ${DIR} remote add origin git@github.com:ysoftwareab/ietf-rfcs-abnf.git
    }

    [[ -n "${DRAFT}" ]] || return

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

            [[ "${i}" = "0" ]] || cp rfcs/rfc${i}.json ${DIR}

            cp id-archive/${DRAFT_NAME}-${draftii}.* ${DIR}
            cp id-archive-abnf/${DRAFT_NAME}-${draftii}.* ${DIR} || true
            cp id-archive-pdf/${DRAFT_NAME}-${draftii}.* ${DIR} || true
            git -C ${DIR} add .
            git -c "commit.gpgsign=false" -c "user.name=${GIT_USER_NAME}" -c "user.email=${GIT_USER_EMAIL}" \
                -C ${DIR} commit -m "${DRAFT_NAME}-${draftii}"
        } || true
    done
}
export -f init_rfc_git

function draft_to_git() {
    local DRAFT_NAME=$1
    local DIR=git/${DRAFT_NAME}

    if git ls-remote | cut -d$'\t' -f2 | grep -q -Fx "refs/heads/${DRAFT_NAME}"; then
        return 0
    fi

    local DRAFT=$(ls id-archive/${DRAFT_NAME}-* | grep "\.txt$" | sed "s/\.txt//" | tail -n1)
    DRAFT=${DRAFT##*/}

    >&2 echo "[DO  ] Creating a git history for ${DRAFT_NAME} in ${DIR} ."

    init_rfc_git 0 "${DIR}" "${DRAFT}"

    >&2 echo "[DONE] Creating a git history for ${DRAFT_NAME} in ${DIR} ."

    >&2 echo "[INFO] Force-pushing git history for ${DRAFT_NAME} to remote origin..."
    git -C ${DIR} push -f origin head:refs/heads/${DRAFT_NAME}
}
export -f draft_to_git

function rfc_to_git() {
    local i=$1
    local DIR=git/rfc${i}

    [[ ! -e "${DIR}" ]] || return 0

    local f="rfcs/rfc${i}.json"
    [[ -e "$f" ]] || return 0

    local DRAFT=$(cat $f | jq -r ".draft" | sed "s/^\s+//" | sed "s/\s+$//" || true)

    if git ls-remote | cut -d$'\t' -f2 | grep -q -Fx "refs/heads/rfc${i}"; then
        return 0
    fi

    >&2 echo "[DO  ] Creating a git history for RFC${i} in ${DIR} ."

    init_rfc_git "$i" "${DIR}" "${DRAFT}"

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
export -f rfc_to_git

parallel -j ${CORES} "rfc_to_git {}" ::: $(seq $(git show origin/master:count) 10000)

# cat list.draft.txt | xargs -L10 parallel -j ${CORES} "draft_to_git {}" :::

# parallel -j ${CORES} "draft_to_git {}" :::
