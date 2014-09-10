#! /usr/bin/awk -f 

# rand-char.awk -- output a random char from each line of input
# $Id: rand-char.awk,v 1.2 1998/07/09 02:29:14 cdua Exp cdua $
# Carlos Duarte, 971027


BEGIN {
	srand()
}

{
	print substr($0, 1 + int(rand()*length), 1)
}
