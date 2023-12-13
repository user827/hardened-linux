#!/bin/sh
set -eu

mainconf=$1
shift

ret=0
for conf; do
  if grep -oFf "$conf"  "$mainconf" | grep -vFf - "$conf"; then
    echo "Not set from $conf" >&2
    ret=1
  fi
done

exit $ret
