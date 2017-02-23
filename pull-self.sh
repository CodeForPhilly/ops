#!/bin/sh
set -e

self_real=$(readlink -f "$0")
self_base=$(dirname "$self_real")

cd "$self_base"
git remote update
distance=$(git status -uno | grep '^Your branch is behind' | head -n1)

if [ -n "$distance" ]; then
  logger --id -t "$self_base" "$distance"
  action=$(git pull | grep '^Updating' | head -n1)
  logger --id -t "$self_base" "$action"
fi
