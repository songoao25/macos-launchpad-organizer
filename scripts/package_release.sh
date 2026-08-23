#!/usr/bin/env sh
set -eu

version=${1:?Usage: scripts/package_release.sh X.Y.Z}
if ! printf '%s' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "ERROR: version must look like X.Y.Z" >&2
  exit 2
fi

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "ERROR: run from a Git checkout" >&2
  exit 2
}

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: commit or stash changes before packaging a release" >&2
  exit 2
fi

name="macos-launchpad-organizer-v${version}.zip"
archive="../${name}"
git archive --format=zip --prefix=macos-launchpad-organizer/ --output="$archive" HEAD
shasum -a 256 "$archive" > "${archive}.sha256"
echo "Created ${archive} and ${archive}.sha256"
