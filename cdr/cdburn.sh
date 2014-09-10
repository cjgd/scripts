#! /bin/sh
# Carlos Duarte, 030224

set -x
tsize=$(mkisofs -r -J -print-size -q "$@")
mkisofs -r -J "$@" |
cdrecord -dao -eject gracetime=2 tsize=${tsize}s -v -
