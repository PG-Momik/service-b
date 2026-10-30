#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
git init -q --bare "$TMP/remote.git"
git init -q "$TMP/work"
git -C "$TMP/work" config user.name Demo
git -C "$TMP/work" config user.email demo@local
git -C "$TMP/work" commit -q --allow-empty -m base
git -C "$TMP/work" branch -M main
git -C "$TMP/work" remote add origin "$TMP/remote.git"
git -C "$TMP/work" push -q origin main
git -C "$TMP/work" checkout -q -b release/2026.11.1
git -C "$TMP/work" push -q origin release/2026.11.1
mkdir -p "$TMP/bin"
cat > "$TMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
if [[ $1 == api ]]; then
  [[ ${MISSING_ARTIFACT:-false} == true ]] || echo 123
  exit 0
fi
if [[ $1 == run && $2 == download ]]; then
  mkdir -p "$7"
  cp "$STAGED_SOURCE"/* "$7/"
  exit 0
fi
printf '%s\n' "$*" >> "$GH_CALLS"
EOF
chmod +x "$TMP/bin/gh"
export PATH="$TMP/bin:$PATH" GITHUB_REPOSITORY=PG-Momik/service-b STAGED_SOURCE="$TMP/staged" GH_CALLS="$TMP/gh-calls"
mkdir -p "$STAGED_SOURCE"
(
  cd "$ROOT"
  STAGED_DIR="$STAGED_SOURCE" bash scripts/demo-image.sh stage "$(git -C "$TMP/work" rev-parse HEAD)"
)
(
  cd "$TMP/work"
  sha=$(git rev-parse HEAD)
  if MISSING_ARTIFACT=true bash "$ROOT/scripts/demo-image.sh" check "$sha"; then
    echo 'Missing staged image was accepted' >&2
    exit 1
  fi
  echo wrong > "$STAGED_SOURCE/image-sha"
  if bash "$ROOT/scripts/demo-image.sh" check "$sha"; then
    echo 'Mismatched staged image was accepted' >&2
    exit 1
  fi
  echo "$sha" > "$STAGED_SOURCE/image-sha"
  digest=$(bash "$ROOT/scripts/demo-image.sh" check "$sha")
  [[ $digest == "$(cat "$STAGED_SOURCE/image-digest")" ]]
  RELEASE_BRANCH=release/2026.11.1 GITHUB_ACTOR=Demo bash "$ROOT/scripts/tag-release.sh"
  git ls-remote --tags origin refs/tags/v2026.11.1 | grep -q v2026.11.1
  grep -qx 'workflow run workflow-1.yml --ref v2026.11.1' "$GH_CALLS"
  RELEASE_BRANCH=release/2026.11.1 GITHUB_REF=refs/tags/v2026.11.1 bash "$ROOT/scripts/promote-demo.sh" | grep -q "Promoted staged image $digest"
  git checkout -q main
  git commit -q --allow-empty -m unrelated
  git tag v2026.11.2
  if RELEASE_BRANCH=release/2026.11.1 GITHUB_REF=refs/tags/v2026.11.2 bash "$ROOT/scripts/promote-demo.sh"; then
    echo 'Tag outside the branch tip was accepted' >&2
    exit 1
  fi
)
echo 'Release flow tests passed.'
