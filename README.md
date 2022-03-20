# Know your IETF well

![GitHub repo size](https://img.shields.io/github/repo-size/ysoftwareab/know-your-ietf-well)

This repository archives IETF Internet-Drafts, RFCs and erratas as JSON/HTML/PDF/text,
and extracts their ABNF grammars.

Each RFC gets its own git branch for easy diffs/blame/history :rocket: .

A list of all RFCs is available [here](./list.md).

If you want to get the history of only one RFC, you can `git clone` only its respective branch

`RFC=7230; git clone -b rfc${RFC} --single-branch git://github.com/ysoftwareab/know-your-ietf-well.git rfc${RFC}`


## Why?

Long story short: it is close to impossible to keep track of changes
in Internet-Drafts/RFCs/erratas and their ABNFs.

Long story: Almost 10 years ago, we have ported ABNFs related to HTTP to PEGjs, namely in
https://github.com/for-GET/core-pegjs and
https://github.com/for-GET/api-pegjs .
Meanwhile drafts became RFCs, RFCs got erratas, etc.

Trying to bring the PEGjs grammars up to date obviously became a laborious project,
precisely because there was no other way to know what changed than to click-click through IETF's web UI.


## Process

We make use of IETF's rsync services to sync Internet-Drafts and RFCS
* https://www.ietf.org/how/ids/internet-draft-mirror-sites/
* https://www.rfc-editor.org/retrieve/rsync/

Erratas get fetched from https://www.rfc-editor.org/rfc/inline-errata/ .

ABNFs get extract with IETF's `aex` tool, available at
https://github.com/ietf-tools/bap/blob/de05dd1/aex .

All content is stored under `refs/rsync/`
* rfcs https://github.com/ysoftwareab/know-your-ietf-well/tree/refs/rsync/rfcs
* rfcs-pdf https://github.com/ysoftwareab/know-your-ietf-well/tree/refs/rsync/rfcs-pdf
* rfcs-ien-scanned https://github.com/ysoftwareab/know-your-ietf-well/tree/refs/rsync/rfcs-ien-scanned
* rfcs-abnf https://github.com/ysoftwareab/know-your-ietf-well/tree/refs/rsync/rfcs-abnf
* id-archive https://github.com/ysoftwareab/know-your-ietf-well/tree/refs/rsync/id-archive
* id-archive-pdf https://github.com/ysoftwareab/know-your-ietf-well/tree/refs/rsync/id-archive-pdf
* id-archive-abnf https://github.com/ysoftwareab/know-your-ietf-well/tree/refs/rsync/id-archive-abnf

`./update.sh` will update (rsync and git push) all of the above refs.

`./to-git.sh` will create one git branch for each RFC with its own "draft/s -> RFC -> errata" history.


## License

[UNLICENSE](UNLICENSE)
