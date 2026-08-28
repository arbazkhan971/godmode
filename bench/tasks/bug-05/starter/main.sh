#!/usr/bin/env bash
# vaultpack: back up the files named in a manifest from staging into the vault.
# Usage: bash main.sh MANIFEST|- STAGING VAULT
set -u

usage="usage: bash main.sh MANIFEST|- STAGING VAULT"
if [ "$#" -ne 3 ]; then
  echo "$usage" >&2
  exit 2
fi
manifest=$1
staging=$2
vault=$3

if [ ! -d "$staging" ]; then
  echo "error: not a directory: $staging" >&2
  exit 1
fi
mkdir -p -- "$vault" || exit 1

names=$(cat "$manifest")
count=0
for name in $names; do
  if ! cp -- "$staging/$name" "$vault/$name"; then
    echo "error: cannot back up: $name" >&2
    exit 1
  fi
  echo "backed up: $name"
  count=$((count + 1))
done
echo "total: $count file(s)"
exit 0
