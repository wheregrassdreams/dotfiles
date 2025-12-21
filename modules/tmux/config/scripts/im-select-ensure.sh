#!/bin/sh
set -eu

# Ensures the requested IM layout is applied only if the current layout differs.
cmd=${1:?}
layout=${2:?}
current=$("$cmd")
if [ "$current" != "$layout" ]; then
  "$cmd" "$layout" >/dev/null 2>&1
fi
