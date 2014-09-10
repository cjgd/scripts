#! /bin/awk -f

# unify.awk -- output only distinct lines, per order of appearance
# $Id: unify.awk,v 1.1 1998/07/09 02:02:11 cdua Exp cdua $
# Carlos Duarte, 980708

# !x[$0]++

x[$0]++ == 0 { print }
