#!/usr/bin/env bash
set -euo pipefail

ref=$1
image=${ref%%/*}
release=${ref#*/}

if [[ ! $release =~ ^([0-9]+(\.[0-9]+)+)(-([0-9]+))?$ ]]; then
  echo "Release tag must be <image>/<version> or <image>/<version>-<revision>, got: $ref" >&2
  exit 1
fi
version=${BASH_REMATCH[1]}
revision=${BASH_REMATCH[4]:-0}

dockerfile="$image/Dockerfile"
if [ ! -f "$dockerfile" ]; then
  echo "No $dockerfile for release $ref" >&2
  exit 1
fi

pinned=$(sed -nE 's/^ARG VERSION=([^ ]+)$/\1/p' "$dockerfile" | head -n 1)
if [ "$pinned" != "$version" ]; then
  echo "Release $ref is version $version, but $dockerfile has ARG VERSION='$pinned'" >&2
  exit 1
fi

releases=$(git tag -l "$image/*" | sed "s|^$image/||" | grep -E '^[0-9]+(\.[0-9]+)+(-[0-9]+)?$' || true)
newest_version=$(sed -E 's/-[0-9]+$//' <<< "$releases" | sort -V | tail -n 1)
newest_revision=$({ grep -E "^${version//./\\.}(-[0-9]+)?$" <<< "$releases" || true; } | sed -E 's/^[^-]+-?//; s/^$/0/' | sort -n | tail -n 1)

tags=()
if [ "$revision" != 0 ]; then
  tags+=("$version-$revision")
fi
if [ "$revision" = "${newest_revision:-0}" ]; then
  tags+=("$version")
  if [ "$version" = "$newest_version" ]; then
    major=${version%%.*}
    minor=$(cut -d. -f1-2 <<< "$version")
    while IFS= read -r moving; do
      moving=${moving//\{major\}/$major}
      tags+=("${moving//\{minor\}/$minor}")
    done < <(jq -r --arg image "$image" '.[$image] // [] | .[]' .github/images.json)
  fi
fi

if [ ${#tags[@]} -eq 0 ]; then
  echo "Release $ref is superseded by $image/$version-$newest_revision, nothing to publish" >&2
  exit 1
fi

echo "image=$image"
echo "repo=bitcart/$image"
echo "tags<<EOF"
for tag in "${tags[@]}"; do
  echo "type=raw,value=$tag"
done
echo "EOF"
