#!/bin/sh
set -e

self_real=$(readlink -f "$0")
self_base=$(dirname "$self_real")

cd "$self_base"
git remote update | logger --id -t "$self_base"
distance=$(git status -uno | grep '^Your branch is behind' | head -n1)

if [ -n "$distance" ]; then
  logger --id -t "$self_base" "$distance"
  git pull | logger --id -t "$self_base"
fi
