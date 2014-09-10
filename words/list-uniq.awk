#! /usr/bin/awk -f 

# list-uniq -- normalize a list
# $Id: list-uniq.awk,v 1.2 1998/07/09 02:27:49 cdua Exp cdua $
# Carlos Duarte, 970305/971117

# usage: set path = ( `echo $path | a-norm ` )
# 	
# this will uniqify an array, i.e. unify it, to avoid getting 
# repeated entries, but keeping its original order
# 
# this is particularly good to use on path vars

# feed next line to debug 
#echo a b c A d e f A g h A i A j A k A A B A A B A B A B 

# should produce
# a
# b
# c
# A
# d
# e
# f
# g
# h
# i
# j
# k
# B

{
	for (i=1; i<=NF; i++) 
		if (!x[$i]++)
			print $i
}
