#!/bin/sh
set -eu

errofu() {
  if [ $? != 0 ]; then
    echo validation failed
  fi
}

trap errofu 0

curdir=$(cd "$(dirname "$0")" && pwd)

mainconf=$1
shift

ret=0
for conf; do
  # list items that are in conf but not in mainconf
  if grep -oFf "$conf"  "$mainconf" | grep -vFf - "$conf"; then
    echo "error for $conf"
    ret=1
  fi
done

exit $ret

#if grep -oFf "$curdir"/confksp  "$1" | grep -vFf - "$curdir"/confksp; then
#  exit 1
#fi
#if grep -oFf "$curdir"/confmy  "$1" | grep -vFf - "$curdir"/confmy; then
#  exit 1
#fi
#if grep -oFf "$curdir"/confhardened  "$1" | grep -vFf - "$curdir"/confhardened; then
#  exit 1
#fi
