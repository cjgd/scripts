#! /usr/bin/awk -f 

# catn -- display files preceded by count
# $Id: catn.awk,v 1.2 1998/07/09 02:04:01 cdua Exp cdua $
# Carlos Duarte, 970304/980706


{
	printf "%6d\t%s\n", ++l, $0
}
