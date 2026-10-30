#!/usr/bin/env bash
set -euo pipefail

branch=${RELEASE_BRANCH:?}
[[ $branch =~ ^release/[0-9]{4}\.[0-9]{2}\.[0-9]+(\.[0-9]+)?$ ]] || { echo 'Invalid release branch' >&2; exit 1; }
git fetch --quiet origin "+refs/heads/$branch:refs/remotes/origin/$branch" --tags
sha=$(git rev-parse --verify "${GITHUB_REF:?}^{commit}")
[[ $sha == "$(git rev-parse --verify "origin/$branch^{commit}")" ]] || { echo 'Tag is not on the release branch tip' >&2; exit 1; }
digest=$(bash "$(dirname "$0")/demo-image.sh" check "$sha")
echo "Promoted staged image $digest for $sha"
