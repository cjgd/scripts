#! /usr/bin/awk -f 

# del-c-cmnt.awk -- delete comments on C code
# $Id: del-c-cmnt.awk,v 1.1 1998/07/09 02:01:04 cdua Exp cdua $
# Carlos Duarte, 980708

# usage: ./del-c-cmnt.awk < file.c  | more
# does not check if inside string

function cl() {
	cont = 1
	if (i = index($0, "*/")) {
		cont = 0
		$0 = substr($0, i+2)
	}
	return cont
}

{
	if (cont && cl())
		next 

	while (i = index($0, "/*")) {
		printf "%s ", substr($0, 1, i-1)
		$0 = substr($0, i+1)
		if (cl())
			next
	}
	print
}
