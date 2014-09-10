#! /bin/sh
# Carlos Duarte, 050801
# waitpid.sh -- waits for a pid to disappear

if test $# -eq 0; then
	echo "usage: $0 pid1 pid2 ..."
	exit 1
fi

while : ; do 
	sleep 1
	for pid 
	do
		kill -0 $pid 2> /dev/null && continue 2
	done
	break 2
done
