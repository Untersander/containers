#!/usr/bin/env bash
# Prints image:tag for each tag of the app in the current directory, tags like home-operations/containers.
# The first one is unique to this version, so it shows if the version has an image yet
set -euo pipefail

variable() {
  buildx bake --list type=variables,format=json --progress=quiet \
    | jq -r --arg name "$1" '.[] | select(.name == $name) | .value'
}
version=$(variable VERSION)

# 2.92_p2-r0 -> raw 2.92_p2, semantic 2.92.0
raw="${version#v}"
raw="${raw%%-*}"
if [[ "$raw" =~ ^([0-9]+)(\.([0-9]+))?(\.([0-9]+))? ]]; then
  semantic="${BASH_REMATCH[1]}.${BASH_REMATCH[3]:-0}.${BASH_REMATCH[5]:-0}"
else
  raw="$version"
  semantic=$(date +%Y.%-m.%-d)
fi

# The bake file's APP is the image name, apps/sonarr-develop pushes pre-releases to sonarr.
# Pre-release apps set TAG, the semver form of their version: 5.0.0.2870 -> 5.0.0-dev.2870
image=$(variable APP)
prerelease=$(variable TAG)
if [[ -n "$prerelease" ]]; then
  tags=$(printf '%s\n' "$prerelease" rolling-dev)
else
  tags=$(printf '%s\n' "$raw" "$semantic" rolling | awk '!seen[$0]++')
fi

for tag in $tags; do
  echo "${image}:${tag}"
done
