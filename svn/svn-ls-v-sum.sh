#! /bin/sh

# svn-ls-v-sum.sh -- prints total used file size from a "svn ls -v" output
# Carlos Duarte, 070201

# usage: 
# svn ls -vR > xxx.out
# svn-ls-v-sum.sh xxx.out
# total sum of bytes used 

cut -c17-29 $* | sed -n '
	/[0-9]/!d
	p
	$!bb
	s/.*/p/
	p
	q
	:b
	${
		s/.*/p/
		p
		q
	}
	n
	/[0-9]/!bb
	s/$/ +/
	p
	bb
' | dc
