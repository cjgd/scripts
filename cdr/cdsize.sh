#! /bin/sh
# Carlos Duarte, 030224

mkisofs -r -J -print-size -q "$@" | 
awk '{printf "%d %.2fMB\n", $1, $1/512+.005}'
