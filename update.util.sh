#!/usr/bin/env bash
set -euo pipefail

GIT_USER_NAME="Andrei Neculau"
GIT_USER_EMAIL="andrei.neculau@gmail.com"

function reset_git_ref() {
    local GIT_REF=$1

    [[ -n "$(git remote)" ]] || \
        git remote add origin git@github.com:ysoftwareab/ietf-rfcs-abnf.git
    if git ls-remote | cut -d$'\t' -f2 | grep -q -Fx "${GIT_REF}"; then
        git fetch -f --update-head-ok origin ${GIT_REF}:${GIT_REF}
    else
        git checkout -b ${GIT_REF##*/}
        git init
        git -c "commit.gpgsign=false" -c "user.name=${GIT_USER_NAME}" -c "user.email=${GIT_USER_EMAIL}" \
            commit --allow-empty -m "[empty] initial commit"
    fi
    git checkout -f ${GIT_REF##*/}
    git reset --hard ${GIT_REF} --
    git clean -xdf .
}

function update_git_ref() {
    local GIT_REF=$1

    git add --renormalize .
    git update-index --refresh
    git diff-index --quiet HEAD -- || {
        git -c "commit.gpgsign=false" -c "user.name=${GIT_USER_NAME}" -c "user.email=${GIT_USER_EMAIL}" \
            commit -m "$(date --utc --iso-8601=seconds)"
    }

    git push origin head:${GIT_REF}
}
