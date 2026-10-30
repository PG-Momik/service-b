#!/usr/bin/env bash
set -euo pipefail

branch=${RELEASE_BRANCH:?}
[[ $branch =~ ^release/([0-9]{4}\.[0-9]{2}\.[0-9]+(\.[0-9]+)?)$ ]] || { echo 'Invalid release branch' >&2; exit 1; }
tag="v${BASH_REMATCH[1]}"
git fetch --quiet origin "+refs/heads/$branch:refs/remotes/origin/$branch" --tags
sha=$(git rev-parse --verify "refs/remotes/origin/$branch^{commit}")
if git ls-remote --exit-code origin "refs/tags/$tag" >/dev/null 2>&1; then
  echo "Tag already exists: $tag" >&2
  exit 1
fi
bash "$(dirname "$0")/demo-image.sh" check "$sha" >/dev/null
git config user.name 'github-actions[bot]'
git config user.email release-bot
git tag -a "$tag" "$sha" -m "Release $tag approved by ${GITHUB_ACTOR:-unknown}"
git push origin "refs/tags/$tag"
gh workflow run workflow-1.yml --ref "$tag"
