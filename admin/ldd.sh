#! /bin/sh

# ldd.sh -- find share lib deps
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990324

if test $# -eq 0; then
	echo "usage: $0 files ... "
	exit 2
fi

for arg
do
	test $# -gt 1 && echo $arg: 
	if test -x $arg; then 
		LD_TRACE_LOADED_OBJECTS=placeholder $arg
	else
		echo "can't execute \`$arg'"
	fi
done
