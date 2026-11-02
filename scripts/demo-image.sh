#!/usr/bin/env bash
set -euo pipefail

mode=${1:?}
sha=${2:?}
[[ $sha =~ ^[0-9a-f]{40}$ ]] || { echo 'Invalid commit SHA' >&2; exit 1; }

case $mode in
  stage)
    dir=${STAGED_DIR:?}
    mkdir -p "$dir"
    echo "$sha" > "$dir/image-sha"
    shasum -a 256 app.js | awk '{ print $1 }' > "$dir/image-digest"
    ;;
  check)
    run_id=$(gh api "repos/${GITHUB_REPOSITORY:?}/actions/artifacts?name=image-$sha" --jq '.artifacts | map(select(.expired == false)) | .[0].workflow_run.id // empty')
    [[ -n $run_id ]] || { echo "No staged image for $sha" >&2; exit 1; }
    dir=$(mktemp -d)
    gh run download "$run_id" --name "image-$sha" --dir "$dir" >/dev/null
    [[ $(cat "$dir/image-sha") == "$sha" ]] || { echo 'Staged image SHA differs' >&2; exit 1; }
    cat "$dir/image-digest"
    ;;
  *) echo 'Unknown image operation' >&2; exit 1 ;;
esac
