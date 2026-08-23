#!/usr/bin/env sh
set -eu

version=${1:?Usage: scripts/package_release.sh X.Y.Z}
case "$version" in
  *[!0-9.]* | *.*.*.* | .* | *.)
    echo "ERROR: version must look like X.Y.Z" >&2
    exit 2
    ;;
esac

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "ERROR: run from a Git checkout" >&2
  exit 2
}

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: commit or stash changes before packaging a release" >&2
  exit 2
fi

name="macos-launchpad-organizer-v${version}.zip"
git archive --format=zip --prefix=macos-launchpad-organizer/ --output="../${name}" HEAD
echo "Created ../${name}"
