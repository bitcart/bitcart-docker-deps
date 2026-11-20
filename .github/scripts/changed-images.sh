#!/usr/bin/env bash
set -euo pipefail

base=$1

images=()
for dockerfile in */Dockerfile; do
  images+=("${dockerfile%/Dockerfile}")
done

if ! git cat-file -e "$base^{commit}" 2> /dev/null; then
  echo "Base $base is not in the checkout, building all images" >&2
  jq -cn '$ARGS.positional' --args "${images[@]}"
  exit 0
fi

changed=$(git diff --name-only "$base" HEAD)
selected=()
for image in "${images[@]}"; do
  if grep -q "^$image/" <<< "$changed"; then
    selected+=("$image")
  fi
done

jq -cn '$ARGS.positional' --args "${selected[@]}"
